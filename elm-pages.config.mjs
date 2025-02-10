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
<link rel="preconnect" href="https://fonts.gstatic.com" />
<link rel="preconnect" href="https://cdnjs.cloudflare.com" />
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
