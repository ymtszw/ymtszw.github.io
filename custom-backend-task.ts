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

  const debugMode = process.env.DEBUG_MERMAID === "true";
  console.log(`[Mermaid] Found ${matches.length} diagram(s)`);

  // Ensure output directory exists
  const outputDir = "public/images/diagrams";
  if (!existsSync(outputDir)) {
    await mkdir(outputDir, { recursive: true });
  }

  // Ensure temp directory exists
  const tempDir = "temp";
  if (!existsSync(tempDir)) {
    await mkdir(tempDir, { recursive: true });
  }

  // Process all diagrams in parallel
  const processedBlocks = await Promise.all(
    matches.map(async (match, index) => {
      const fullMatch = match[0];
      const mermaidSource = match[1];

      // Generate hash-based ID from source
      const hash = createHash("sha256")
        .update(mermaidSource)
        .digest("hex")
        .substring(0, 16);

      const inputPath = join(tempDir, `${hash}.mmd`);
      const outputPath = join(outputDir, `${hash}.svg`);
      const imagePath = `/images/diagrams/${hash}.svg`;

      try {
        // Check if SVG already exists (cache hit)
        if (existsSync(outputPath)) {
          console.log(`[Mermaid] Cache hit for diagram ${index + 1}: ${hash}`);
          return {
            fullMatch,
            replacement: `![Mermaid Diagram](${imagePath})`,
          };
        }

        // Write mermaid source to temp file
        await writeFile(inputPath, mermaidSource);

        // Execute mermaid-cli to generate SVG
        console.log(
          `[Mermaid] Rendering diagram ${index + 1}/${matches.length}: ${hash}`
        );

        await execAsync(
          `npx mmdc -i ${inputPath} -o ${outputPath} -b transparent`
        );

        // Clean up temp file
        await unlink(inputPath);

        console.log(`[Mermaid] Successfully generated: ${imagePath}`);

        return {
          fullMatch,
          replacement: `![Mermaid Diagram](${imagePath})`,
        };
      } catch (error) {
        // Clean up temp file on error
        try {
          await unlink(inputPath);
        } catch {}

        const errorMessage =
          error instanceof Error ? error.message : String(error);
        console.error(
          `[Mermaid] Failed to render diagram ${index + 1}:`,
          errorMessage
        );

        // Return original mermaid block on error (fallback)
        return {
          fullMatch,
          replacement: fullMatch,
        };
      }
    })
  );

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
