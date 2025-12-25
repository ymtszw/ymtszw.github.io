import { imageSizeFromFile } from "image-size/fromFile";
import { exec } from "child_process";
import { promisify } from "util";
import { createHash } from "crypto";
import { writeFile, unlink, mkdir } from "fs/promises";
import { existsSync } from "fs";
import { join } from "path";

const execAsync = promisify(exec);

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

/**
 * Process Mermaid diagrams in Markdown source
 * Extracts ```mermaid blocks, generates SVG images, and replaces them with image references
 *
 * @param { string } markdownSource - Markdown source (with or without frontmatter)
 * @returns { Promise<string> } - Processed markdown source with mermaid blocks replaced
 */
export async function processMermaid(markdownSource: string): Promise<string> {
  const mermaidBlockRegex = /```mermaid\n([\s\S]*?)\n```/g;
  const matches = Array.from(markdownSource.matchAll(mermaidBlockRegex));

  if (matches.length === 0) {
    // No mermaid blocks found, return as-is
    return markdownSource;
  }

  console.log(`[Mermaid] Found ${matches.length} diagram(s)`);

  // Output to both public/ (for dev server) and dist/ (for production build)
  // This ensures images are available in both development and production environments
  const outputDirs = ["public/images/diagrams", "dist/images/diagrams"];

  for (const dir of outputDirs) {
    if (!existsSync(dir)) {
      await mkdir(dir, { recursive: true });
    }
  }

  // Ensure temp directory exists
  const tempDir = "temp";
  if (!existsSync(tempDir)) {
    await mkdir(tempDir, { recursive: true });
  }

  // Process all diagrams sequentially to avoid race conditions with temp files
  const processedBlocks: Array<{ fullMatch: string; replacement: string }> = [];

  for (const [index, match] of matches.entries()) {
    const fullMatch = match[0];
    const mermaidSource = match[1];

    // Generate hash-based ID from source
    const hash = createHash("sha256")
      .update(mermaidSource)
      .digest("hex")
      .substring(0, 16);

    // Use unique temp file name to avoid conflicts (hash + timestamp + random)
    const uniqueId = `${hash}_${Date.now()}_${Math.random()
      .toString(36)
      .substring(7)}`;
    const inputPath = join(tempDir, `${uniqueId}.mmd`);
    const imagePath = `/images/diagrams/${hash}.svg`;

    try {
      // Check if SVG already exists in any output directory (cache hit)
      const outputPaths = outputDirs.map((dir) => join(dir, `${hash}.svg`));
      const cacheHit = outputPaths.some(existsSync);

      if (cacheHit) {
        console.log(`[Mermaid] Cache hit for diagram ${index + 1}: ${hash}`);
        processedBlocks.push({
          fullMatch,
          replacement: `![Mermaid Diagram](${imagePath})`,
        });
        continue;
      }

      // Write mermaid source to temp file
      await writeFile(inputPath, mermaidSource);

      // Execute mermaid-cli to generate SVG
      console.log(
        `[Mermaid] Rendering diagram ${index + 1}/${matches.length}: ${hash}`
      );

      // Generate to all output directories
      for (const outputDir of outputDirs) {
        const outputPath = join(outputDir, `${hash}.svg`);
        await execAsync(
          `npx mmdc -i ${inputPath} -o ${outputPath} -b transparent`
        );
      }

      // Clean up temp file immediately after successful rendering
      await unlink(inputPath).catch((cleanupError) => {
        console.warn(
          `[Mermaid] Failed to clean up temp file: ${inputPath}`,
          cleanupError
        );
      });

      console.log(`[Mermaid] Successfully generated: ${imagePath}`);

      processedBlocks.push({
        fullMatch,
        replacement: `![Mermaid Diagram](${imagePath})`,
      });
    } catch (error) {
      // Clean up temp file on error
      await unlink(inputPath).catch((cleanupError) => {
        console.warn(
          `[Mermaid] Failed to clean up temp file on error: ${inputPath}`,
          cleanupError
        );
      });

      const errorMessage =
        error instanceof Error ? error.message : String(error);
      console.error(
        `[Mermaid] Failed to render diagram ${index + 1}:`,
        errorMessage
      );

      // Return original mermaid block on error (fallback)
      processedBlocks.push({
        fullMatch,
        replacement: fullMatch,
      });
    }
  }

  // Replace all mermaid blocks with image references
  let processedMarkdown = markdownSource;
  for (const block of processedBlocks) {
    processedMarkdown = processedMarkdown.replace(
      block.fullMatch,
      block.replacement
    );
  }

  return processedMarkdown;
}
