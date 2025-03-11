import { imageSizeFromFile } from "image-size/fromFile";

/**
 * Implementation of `BackendTask.File.Extra.getImageDimensions`
 *
 * @param { string } fileName
 * @returns { Promise<{ width: number, height: number }> }
 */
export async function getImageDimensions(
  fileName: string
): Promise<{ width: number; height: number }> {
  const dimensions = await imageSizeFromFile(
    `public/${fileName.replace(/^\//, "")}`
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
