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
  },
  flags: function () {
    return {
      libraryKey: localStorage.getItem("LibraryKey"),
    };
  },
};
