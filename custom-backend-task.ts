import { imageSizeFromFile } from "image-size/fromFile";
import { promises as fs } from "node:fs";

/**
 * Implementation of `BackendTask.File.Extra.getImageDimensions`
 *
 * @param { string } fileName
 * @returns { Promise<{ width: number, height: number }> }
 */
export async function getImageDimensions(
  fileName: string,
): Promise<{ width: number; height: number }> {
  const dimensions = await imageSizeFromFile(
    `public/${fileName.replace(/^\//, "")}`,
  );
  if (dimensions.width && dimensions.height) {
    return {
      width: dimensions.width,
      height: dimensions.height,
    };
  } else {
    throw new Error("Invalid image dimensions");
  }
}

/**
 * Implementation of `BackendTask.File.Extra.dumpJsonFile`
 *
 * @param { fileName: string, json: object } params
 * @returns { Promise<void> }
 */
export async function dumpJsonFile({
  fileName,
  json,
}: {
  fileName: string;
  json: object;
}): Promise<void> {
  await fs.mkdir("tmp", { recursive: true });
  await fs.writeFile(`tmp/${fileName}`, JSON.stringify(json, null, 4), "utf-8");
}
