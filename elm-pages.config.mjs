import { defineConfig } from "vite";

export default {
  vite: defineConfig({
    build: {
      chunkSizeWarningLimit: 3_000,
      cssMinify: "esbuild",
      minify: "esbuild",
    },
  }),
  adapter,
  headTagsTemplate(context) {
    return `
<link rel="stylesheet" href="/style.css" />
<meta name="generator" content="elm-pages v${context.cliVersion}" />
`;
  },
  preloadTagForFile(file) {
    // add preload directives for JS assets and font assets, etc., skip for CSS files
    // this function will be called with each file that is processed by Vite, including any files in your headTagsTemplate in your config
    return !file.endsWith(".css");
  },
};

async function adapter({
  renderFunctionFilePath,
  routePatterns,
  apiRoutePatterns,
}) {
  console.log("Running empty adapter");
  return;
}
