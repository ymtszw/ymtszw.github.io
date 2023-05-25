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
};
