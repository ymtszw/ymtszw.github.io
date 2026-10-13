import { defineConfig } from "vite";
import atImport from "postcss-import";
import adapter from "./adapter/cloudflare-pages.js";

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
<script src="https://cdn.jsdelivr.net/npm/@mermaid-js/tiny@11/dist/mermaid.tiny.js"></script>
<!-- Cloudflare Web Analytics -->
<script defer src="/api/telemetry/script" data-cf-beacon='{"token": "3b9ae30775224b5ba2235efa3df98d4c", "send": {"to": "/api/telemetry"}}'></script>
<!-- End Cloudflare Web Analytics -->
<meta name="generator" content="elm-pages v${context.cliVersion}" />
`;
  },
  preloadTagForFile(file) {
    // add preload directives for JS assets and font assets, etc., skip for CSS files
    // this function will be called with each file that is processed by Vite, including any files in your headTagsTemplate in your config
    return !file.endsWith(".css");
  },
};
