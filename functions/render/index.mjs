import * as path from "path";
import * as busboy from "busboy";
import { fileURLToPath } from "url";
import * as renderer from "elm-pages/generator/src/render.js";
import * as preRenderHtml from "elm-pages/generator/src/pre-render-html.js";
import * as customBackendTask from "/Users/yumatsuzawa/workspace/ymtszw.github.io/.elm-pages/compiled-ports/custom-backend-task.mjs";
const htmlTemplate = "<!DOCTYPE html>\n<!-- ROOT --><html lang=\"en\">\n  <head>\n    <meta charset=\"UTF-8\" />\n    <title><!-- PLACEHOLDER_TITLE --></title>\n    <link rel=\"modulepreload\" crossorigin href=\"/elm.57030dfc.js\"><link rel=\"modulepreload\" crossorigin href=\"/assets/index-ca37dee2.js\">\n    <script defer src=\"/elm.57030dfc.js\" type=\"text/javascript\"></script>\n    \n        \n    <link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.1/normalize.min.css\" integrity=\"sha512-NhSC1YmyruXifcj/KFRWoC561YpHpc5Jtzgvbuzx5VozKpWvQ+4nXhPdFgmx8xqexRcpAglTj9sIBWINXa8x5w==\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\" />\n    <link rel=\"stylesheet\" href=\"https://unpkg.com/sakura.css/css/sakura.css\" type=\"text/css\">\n    \n    <meta name=\"generator\" content=\"elm-pages v3.0.0-beta.33\" />\n    \n    <!-- PLACEHOLDER_HEAD_AND_DATA -->\n    <script type=\"module\" crossorigin src=\"/assets/index-ca37dee2.js\"></script>\n    <link rel=\"stylesheet\" href=\"/assets/index-90ff9e7f.css\">\n  </head>\n  <body>\n    <div data-url=\"\" display=\"none\"></div>\n    <!-- PLACEHOLDER_HTML -->\n  </body>\n</html>";

import { builder } from "@netlify/functions";

export const handler = builder(render);


/**
 * @param {import('aws-lambda').APIGatewayProxyEvent} event
 * @param {any} context
 */
async function render(event, context) {
  const requestTime = new Date();

  try {
    const basePath = "/";
    const mode = "build";
    const addWatcher = () => {};

    const renderResult = await renderer.render(
      customBackendTask,
      basePath,
      (await import("./elm-pages-cli.cjs")).default,
      mode,
      event.path,
      await reqToJson(event, requestTime),
      addWatcher,
      false
    );

    const statusCode = renderResult.is404 ? 404 : renderResult.statusCode;

    if (renderResult.kind === "bytes") {
      return {
        body: Buffer.from(renderResult.contentDatPayload.buffer).toString("base64"),
        isBase64Encoded: true,
        headers: {
          "Content-Type": "application/octet-stream",
          "x-powered-by": "elm-pages",
          ...renderResult.headers,
        },
        statusCode,
      };
    } else if (renderResult.kind === "api-response") {
      const serverResponse = renderResult.body;
      return {
        body: serverResponse.body,
        multiValueHeaders: serverResponse.headers,
        statusCode: serverResponse.statusCode,
        isBase64Encoded: serverResponse.isBase64Encoded,
      };
    } else {
      return {
        body: preRenderHtml.replaceTemplate(htmlTemplate, renderResult.htmlString),
        headers: {
          "Content-Type": "text/html",
          "x-powered-by": "elm-pages",
          ...renderResult.headers,
        },
        statusCode,
      };
    }
  } catch (error) {
    console.error(error);
    console.error(JSON.stringify(error, null, 2));
    return {
      body: `<body><h1>Error</h1><pre>${JSON.stringify(error, null, 2)}</pre></body>`,
      statusCode: 500,
      headers: {
        "Content-Type": "text/html",
        "x-powered-by": "elm-pages",
      },
    };
  }
}

/**
 * @param {import('aws-lambda').APIGatewayProxyEvent} req
 * @param {Date} requestTime
 * @returns {{method: string; rawUrl: string; body: string?; headers: Record<string, string>; requestTime: number; multiPartFormData: unknown }}
 */
function reqToJson(req, requestTime) {
  return {
    method: req.httpMethod,
    headers: req.headers,
    rawUrl: req.rawUrl,
    body: req.body,
    requestTime: Math.round(requestTime.getTime()),
    multiPartFormData: null,
  };
}
