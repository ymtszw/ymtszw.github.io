import "highlight.js/styles/atom-one-light.min.css";
import hljs from "highlight.js";

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

    window.addEventListener("DOMContentLoaded", highlightCodeBlocks);

    app.ports.toJs.subscribe((data: { tag: string; value?: string }) => {
      switch (data.tag) {
        case "TriggerHighlightJs":
          highlightCodeBlocks();
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
      console.log("Highlighting", el);
      hljs.highlightElement(el as HTMLElement);
    });
  });
};

export default config;
