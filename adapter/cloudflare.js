import * as fs from "fs";

export default async function run({
  renderFunctionFilePath,
  routePatterns,
  apiRoutePatterns,
}) {
  console.log("Running Cloudflare Pages adapter");

  // Ensure functions directory exists
  ensureDirSync("functions");

  // Copy render function to functions directory
  fs.copyFileSync(renderFunctionFilePath, "./functions/elm-pages-cli.mjs");

  // Generate the catch-all handler for Cloudflare Pages Functions
  fs.writeFileSync("./functions/[[path]].ts", handlerCode());

  // Generate _routes.json for Cloudflare Pages routing
  const routesJson = generateRoutesJson(routePatterns, apiRoutePatterns);
  fs.writeFileSync("./dist/_routes.json", JSON.stringify(routesJson, null, 2));

  console.log("Cloudflare Pages adapter complete");
}

function ensureDirSync(dirpath) {
  try {
    fs.mkdirSync(dirpath, { recursive: true });
  } catch (err) {
    if (err.code !== "EEXIST") throw err;
  }
}

function isServerSide(route) {
  return (
    route.kind === "prerender-with-fallback" || route.kind === "serverless"
  );
}

function generateRoutesJson(routePatterns, apiRoutePatterns) {
  const serverRoutes = routePatterns
    .filter(isServerSide)
    .map((route) => route.pathPattern);

  const apiServerRoutes = apiRoutePatterns
    .filter(isServerSide)
    .map((route) => pathPatternToString(route.pathPattern));

  const allServerRoutes = [...serverRoutes, ...apiServerRoutes];

  // If there are no server routes, we can skip _routes.json
  if (allServerRoutes.length === 0) {
    return {
      version: 1,
      include: ["/*"],
      exclude: [],
    };
  }

  return {
    version: 1,
    include: allServerRoutes,
    exclude: [],
  };
}

function pathPatternToString(pathPattern) {
  return (
    "/" +
    pathPattern
      .map((segment, index) => {
        switch (segment.kind) {
          case "literal": {
            return segment.value;
          }
          case "dynamic": {
            return `:dynamic${index}`;
          }
          case "hybrid": {
            return `*`;
          }
          default: {
            throw "Unhandled segment: " + JSON.stringify(segment);
          }
        }
      })
      .join("/")
  );
}

function handlerCode() {
  return `// @ts-nocheck
import * as elmPages from "./elm-pages-cli.mjs";

/**
 * Cloudflare Pages Functions handler
 * @param {Request} request
 * @param {EventContext} context
 */
export async function onRequest(context) {
  try {
    const renderResult = await elmPages.render(await reqToJson(context.request));
    const { headers, statusCode } = renderResult;

    const responseHeaders = new Headers();
    for (const [key, values] of Object.entries(headers)) {
      for (const value of values) {
        responseHeaders.append(key, value);
      }
    }
    responseHeaders.set("x-powered-by", "elm-pages");

    if (renderResult.kind === "bytes") {
      responseHeaders.set("Content-Type", "application/octet-stream");
      return new Response(renderResult.body, {
        status: statusCode,
        headers: responseHeaders,
      });
    } else if (renderResult.kind === "api-response") {
      const body = renderResult.isBase64Encoded
        ? Uint8Array.from(atob(renderResult.body), c => c.charCodeAt(0))
        : renderResult.body;
      return new Response(body, {
        status: statusCode,
        headers: responseHeaders,
      });
    } else {
      responseHeaders.set("Content-Type", "text/html");
      return new Response(renderResult.body, {
        status: statusCode,
        headers: responseHeaders,
      });
    }
  } catch (error) {
    console.error(error);
    console.error(JSON.stringify(error, null, 2));
    return new Response(
      \`<body><h1>Error</h1><pre>\${JSON.stringify(error, null, 2)}</pre></body>\`,
      {
        status: 500,
        headers: {
          "Content-Type": "text/html",
          "x-powered-by": "elm-pages",
        },
      }
    );
  }
}

/**
 * @param {Request} req
 * @returns {{requestTime: number; method: string; rawUrl: string; body: string | null; headers: Record<string, string>; multiPartFormData: unknown }}
 */
async function reqToJson(req) {
  const headers = {};
  for (const [key, value] of req.headers.entries()) {
    headers[key] = value;
  }

  let body = null;
  let multiPartFormData = null;

  if (req.method !== "GET" && req.method !== "HEAD") {
    const contentType = req.headers.get("content-type") || "";

    if (contentType.includes("multipart/form-data")) {
      // Handle multipart form data
      const formData = await req.formData();
      multiPartFormData = {};
      for (const [key, value] of formData.entries()) {
        multiPartFormData[key] = value;
      }
    } else {
      // Handle regular body
      body = await req.text();
    }
  }

  return {
    requestTime: Math.round(new Date().getTime()),
    method: req.method,
    headers,
    rawUrl: req.url,
    body,
    multiPartFormData,
  };
}
`;
}
