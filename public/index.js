/** @typedef {{load: (Promise<unknown>); flags: (unknown)}} ElmPagesInit */

/** @type ElmPagesInit */
export default {
  load: async function (elmLoaded) {
    const app = await elmLoaded;
    console.log("App loaded", app);
    app.ports.toJs.subscribe((data) => {
      switch (data.tag) {
        case "StoreLibraryKey":
          localStorage.setItem("LibraryKey", data.value);
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
        if (ticking > 5) {
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
