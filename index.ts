import "highlight.js/styles/atom-one-light.min.css";
import hljs from "highlight.js";
import mermaid from "mermaid";

type ElmPagesInit = {
  load: (elmLoaded: Promise<unknown>) => Promise<void>;
  flags: unknown;
};

type App = {
  ports: {
    toJs: {
      subscribe: (
        callback: (data: { tag: string; value: string }) => unknown
      ) => unknown;
    };
    fromJs: {
      send: (data: {
        viewportHeight: number;
        viewportTop: number;
        viewportBottom: number;
      }) => unknown;
    };
  };
};

const config: ElmPagesInit = {
  load: async function (elmLoaded) {
    const app = (await elmLoaded) as App;
    console.log("App loaded", app);

    app.ports.toJs.subscribe((data: { tag: string; value?: string }) => {
      switch (data.tag) {
        case "TriggerHighlightJs":
          highlightCodeBlocks();
          break;
        case "TriggerMermaidRender":
          renderMermaidDiagrams();
          break;
        case "StoreLibraryKey":
          data.value && localStorage.setItem("LibraryKey", data.value);
          console.log("LibraryKey stored");
          break;
        default:
          console.log("Unknown message type", data);
      }
    });

    let ticking = 0;
    window.addEventListener(
      "scroll",
      (event) => {
        if (ticking > 10) {
          window.requestAnimationFrame(() => {
            app.ports.fromJs.send({
              viewportHeight: window.innerHeight,
              viewportTop: window.scrollY,
              viewportBottom: window.scrollY + window.innerHeight,
            });
            ticking = 0;
          });
        }
        ticking += 1;
      },
      { passive: true }
    );
  },
  flags: function () {
    return {
      libraryKey: localStorage.getItem("LibraryKey"),
      viewport: {
        viewportHeight: window.innerHeight,
        viewportTop: window.scrollY,
        viewportBottom: window.scrollY + window.innerHeight,
      },
    };
  },
};

const highlightCodeBlocks = () => {
  requestAnimationFrame(() => {
    document.querySelectorAll("pre code").forEach((el) => {
      // Skip Mermaid code blocks as they are rendered as diagrams
      if (el.classList.contains("language-mermaid")) {
        return;
      }
      console.log("Highlighting", el);
      hljs.highlightElement(el as HTMLElement);
    });
  });
};

const renderMermaidDiagrams = () => {
  requestAnimationFrame(async () => {
    const mermaidBlocks = document.querySelectorAll(
      "pre code.language-mermaid"
    );

    if (mermaidBlocks.length > 0) {
      console.log(`Rendering ${mermaidBlocks.length} mermaid diagram(s)`);

      // Initialize mermaid
      mermaid.initialize({
        startOnLoad: false,
        theme: "default",
      });

      try {
        // Replace each code block with a mermaid div
        mermaidBlocks.forEach((block) => {
          const pre = block.parentElement;
          if (pre && !pre.dataset.mermaidRendered) {
            const mermaidCode = block.textContent || "";
            const div = document.createElement("div");
            div.className = "mermaid";
            div.textContent = mermaidCode;
            pre.replaceWith(div);
            pre.dataset.mermaidRendered = "true";
          }
        });

        // Render all mermaid diagrams
        await mermaid.run({
          querySelector: ".mermaid:not([data-processed])",
        });
      } catch (err) {
        console.error("Mermaid rendering failed:", err);
      }
    }
  });
};

export default config;
