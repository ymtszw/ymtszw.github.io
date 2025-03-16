import { defineConfig } from "vite";
import atImport from "postcss-import";

export default {
  vite: defineConfig({
    build: {
      chunkSizeWarningLimit: 3_000,
      cssMinify: "esbuild",
      minify: "esbuild",
    },
    css: {
      devSourcemap: true,
      transformer: "postcss",
      postcss: {
        plugins: [atImport()],
      },
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
  console.log("[EA] Running Empty Adapter");
  console.log("[EA] renderFunctionFilePath", renderFunctionFilePath);
  console.log("[EA] routePatterns", routePatterns);
  console.log("[EA] apiRoutePatterns", apiRoutePatterns);
  return;
}
