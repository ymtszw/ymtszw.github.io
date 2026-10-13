/**
 * Cloudflare Pages adapter for elm-pages v3
 *
 * This adapter enables deploying elm-pages applications to Cloudflare Pages with full
 * server-side rendering support using Cloudflare Pages Functions.
 *
 * Features:
 * - Generates a catch-all handler (`functions/[[path]].ts`) for server-rendered routes
 * - Creates `_routes.json` to control which routes use Functions vs static assets
 * - Converts between Fetch API (Request/Response) and elm-pages render format
 * - Supports server-render routes with access to request data (headers, method, URL, body)
 *
 * How it works:
 * 1. Copies the elm-pages render engine to `functions/elm-pages-cli.mjs`
 * 2. Generates a TypeScript handler that implements Cloudflare Pages Functions' `onRequest`
 * 3. Creates `_routes.json` based on route patterns to route serverless routes to Functions
 * 4. Static routes and assets are served directly from `dist/` without Functions overhead
 *
 * References:
 * - Cloudflare Pages Functions: https://developers.cloudflare.com/pages/functions/
 * - Functions Routing: https://developers.cloudflare.com/pages/functions/routing/
 * - _routes.json spec: https://developers.cloudflare.com/pages/functions/routing/#functions-invocation-routes
 */
import * as fs from "fs";

export default async function run({
  renderFunctionFilePath,
  routePatterns,
  apiRoutePatterns,
}) {
  console.log("Running Cloudflare Pages adapter");

  // Array to record paths of files created or copied
  const generatedFiles = [];

  // Ensure functions directory exists
  ensureDirSync("functions");

  // Copy render function to functions directory
  fs.copyFileSync(renderFunctionFilePath, "./functions/elm-pages-cli.mjs");
  // Normalize Windows absolute paths in imports
  let cliContent = fs.readFileSync("./functions/elm-pages-cli.mjs", "utf8");
  cliContent = cliContent
    .replace(/from\s*"[^"]*elm\.cjs"/g, 'from "../elm-stuff/elm-pages/elm.cjs"')
    .replace(/from\s*"[^"]*custom-backend-task\.mjs"/g, 'from "../.elm-pages/compiled-ports/custom-backend-task.mjs"');
  fs.writeFileSync("./functions/elm-pages-cli.mjs", cliContent);
  generatedFiles.push("functions/elm-pages-cli.mjs");

  // Generate the catch-all handler for Cloudflare Pages Functions
  fs.writeFileSync("./functions/[[path]].ts", handlerCode());
  generatedFiles.push("functions/[[path]].ts");

  // Generate _routes.json for Cloudflare Pages routing
  const routesJson = generateRoutesJson(routePatterns, apiRoutePatterns);
  fs.writeFileSync("./dist/_routes.json", JSON.stringify(routesJson, null, 2));
  generatedFiles.push("dist/_routes.json");

  console.log("Cloudflare Pages adapter complete");
  console.log(
    "[Cloudflare Adapter] Generated files:\n" +
      generatedFiles.map((f) => `  - ${f}`).join("\n")
  );
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

  const customFunctionRoutes = ["/api/telemetry*"];
  const allServerRoutes = [
    ...serverRoutes,
    ...apiServerRoutes,
    ...customFunctionRoutes,
  ];

  // Exclude static assets from Functions routing
  const staticAssetPatterns = [
    "/assets/*",
    "/*.html",
    "/*.js",
    "/*.css",
    "/*.json",
    "/*.txt",
    "/*.xml",
    "/*.ico",
    "/*.png",
    "/*.jpg",
    "/*.jpeg",
    "/*.gif",
    "/*.svg",
    "/*.webp",
    "/*.woff",
    "/*.woff2",
    "/*.ttf",
    "/*.eot",
  ];

  // If there are no server routes, we can skip _routes.json
  if (allServerRoutes.length === 0) {
    return {
      version: 1,
      include: ["/*"],
      exclude: staticAssetPatterns,
    };
  }

  return {
    version: 1,
    include: allServerRoutes,
    exclude: staticAssetPatterns,
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
  const { request } = context;
  const url = new URL(request.url);

  // Cloudflare Web Analytics First-Party Proxy
  if (url.pathname === "/api/telemetry/script" || url.pathname === "/api/telemetry/beacon.js") {
    if (request.method === "GET" || request.method === "HEAD") {
      const beaconUrl = "https://static.cloudflareinsights.com/beacon.min.js";
      try {
        const res = await fetch(beaconUrl, {
          headers: {
            "User-Agent": request.headers.get("User-Agent") || "",
          },
        });
        return new Response(request.method === "HEAD" ? null : res.body, {
          status: res.status,
          headers: {
            "Content-Type": "application/javascript; charset=utf-8",
            "Cache-Control": "public, max-age=86400, s-maxage=604800",
          },
        });
      } catch (err) {
        console.error("Beacon proxy error:", err);
        return new Response("console.warn('Beacon proxy failed');", {
          status: 502,
          headers: {
            "Content-Type": "application/javascript; charset=utf-8",
          },
        });
      }
    }
    return new Response("Method Not Allowed", { status: 405 });
  }

  if (url.pathname === "/api/telemetry") {
    if (request.method === "POST") {
      const targetUrl = "https://cloudflareinsights.com/cdn-cgi/rum";
      const headers = new Headers();
      headers.set("Content-Type", request.headers.get("Content-Type") || "application/json");
      headers.set("User-Agent", request.headers.get("User-Agent") || "");
      if (request.headers.has("Origin")) {
        headers.set("Origin", request.headers.get("Origin"));
      }
      if (request.headers.has("Referer")) {
        headers.set("Referer", request.headers.get("Referer"));
      }
      const clientIp = request.headers.get("CF-Connecting-IP");
      if (clientIp) {
        headers.set("CF-Connecting-IP", clientIp);
        headers.set("X-Forwarded-For", clientIp);
      }
      try {
        const upstreamResponse = await fetch(targetUrl, {
          method: "POST",
          headers,
          body: request.body,
        });
        return new Response(upstreamResponse.body, {
          status: upstreamResponse.status,
          headers: {
            "Content-Type": upstreamResponse.headers.get("Content-Type") || "text/plain",
          },
        });
      } catch (err) {
        console.error("Telemetry proxy error:", err);
        return new Response(JSON.stringify({ error: "Telemetry proxy failed", message: String(err) }), {
          status: 502,
          headers: { "Content-Type": "application/json" },
        });
      }
    } else if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type",
        },
      });
    }
    return new Response("Method Not Allowed", { status: 405 });
  }

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
    // Mark responses so clients and CI can detect adapter runtime
    responseHeaders.set("x-elm-pages-cloudflare", "true");

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
          "x-elm-pages-cloudflare": "true",
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
  // Mark this request as coming from Cloudflare Pages Functions
  headers["x-elm-pages-cloudflare"] = "true";
  console.log("[Cloudflare Adapter] Inserting x-elm-pages-cloudflare header");

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
