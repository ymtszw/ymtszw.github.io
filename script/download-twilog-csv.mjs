import { chromium } from 'playwright-core';
import path from 'node:path';
import fs from 'node:fs/promises';
import os from 'node:os';

const PROFILE_DIR =
  process.env.TWILOG_CHROME_PROFILE_DIR ||
  path.join(os.homedir(), '.chrome-profiles', 'twilog-sync');
const SETTING_URL = 'https://twilog.togetter.com/setting';
const DOWNLOAD_DIR = path.join(os.homedir(), 'Downloads');

async function main() {
  const headless = process.env.HEADLESS !== 'false';
  const context = await chromium.launchPersistentContext(PROFILE_DIR, {
    channel: 'chrome',
    headless,
    acceptDownloads: true,
    viewport: { width: 1280, height: 900 },
  });

  try {
    const page = context.pages()[0] || (await context.newPage());
    await page.goto(SETTING_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await page.waitForLoadState('networkidle', { timeout: 10000 }).catch(() => {});

    const utf8Button = page
      .locator('a, button, input[type="submit"], input[type="button"]')
      .filter({ hasText: /CSV\s*\(?\s*UTF-?8\s*\)?/i })
      .first();

    if ((await utf8Button.count()) === 0) {
      console.error(
        `AUTH_REQUIRED: UTF-8 CSV button not found at ${page.url()}. ` +
          `Please log in to Twilog using the dedicated Chrome profile (${PROFILE_DIR}) and close the browser.`
      );
      process.exitCode = 2;
      return;
    }

    const [download] = await Promise.all([
      page.waitForEvent('download', { timeout: 60000 }),
      utf8Button.click(),
    ]);

    const suggested = download.suggestedFilename() || 'twilog_utf8.csv';
    const destPath = path.join(DOWNLOAD_DIR, suggested);
    await download.saveAs(destPath);

    const stat = await fs.stat(destPath);
    console.log(`Downloaded: ${destPath} (${stat.size} bytes)`);
  } finally {
    await context.close();
  }
}

main().catch((err) => {
  console.error('ERROR:', err.message || err);
  process.exit(1);
});
