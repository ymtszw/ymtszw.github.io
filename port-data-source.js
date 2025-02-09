module.exports = {
  /**
   * Implementation of `DataSource.Env.load`
   *
   * @param { string } varName
   * @returns { Promise<string> }
   */
  loadEnv: async function (varName) {
    const result = process.env[varName];
    if (result) {
      return result;
    } else {
      throw `No environment variable called ${varName}\n\nAvailable: ${Object.keys(
        process.env
      ).join(", ")}`;
    }
  },
  /**
   * Implementation of `DataSource.File.Extra.stat`
   *
   * @param { string } fileName
   * @returns { Promise<fs.Stats> }
   * @see https://nodejs.org/api/fs.html#class-fsstats
   */
  statFile: async function (fileName) {
    const result = await require("fs").promises.stat(fileName);
    return {
      size: result.size,
      mtime: result.mtime,
      birthtime: result.birthtime,
    };
  },
  /**
   * Implementation of `DataSource.File.Extra.getImageDimensions`
   *
   * @param { string } fileName
   * @returns { Promise<{ width: number, height: number }> }
   */
  getImageDimensions: async function (fileName) {
    const imageSizeFromFile = require("image-size");
    const dimensions = await imageSizeFromFile(
      `public/${fileName.replace(/^\//, "")}`
    );
    return {
      width: dimensions.width,
      height: dimensions.height,
    };
  },
};
