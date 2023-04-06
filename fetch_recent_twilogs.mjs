/**
 * Must be run as: npm run fetch_recent_twilogs
 *
 * This script fetch CSV from $MY_TWILOG_CSV_URL and convert it to JSON,
 * then split it into daily chunks and save them to the data/ directory.
 * New diffs have to be committed to git either manually or by scheduled workflow.
 *
 */

import fetch from "node-fetch";
import csv from "csvtojson";
import { mkdir, writeFile, readFile } from "fs/promises";
import { existsSync } from "fs";

const previousCursor = Number.parseInt(
  await readFile("data/MY_TWILOGS_CSV_CURSOR")
);

let cursor = previousCursor;
let groupedByYearMonthDay = {};
const resp = await fetch(process.env.MY_TWILOG_CSV_URL);
csv({ delimiter: "," })
  .fromStream(resp.body)
  .subscribe(
    (tweet, lineNumber) => {
      if (lineNumber <= previousCursor) {
        return;
      } else {
        cursor = lineNumber;
      }
      // TZ env var must be set. See package.json
      const ca = new Date(tweet.CreatedAt);
      const yearMonthDay = [
        ca.getFullYear(),
        (ca.getMonth() + 1).toString().padStart(2, "0"),
        ca.getDate().toString().padStart(2, "0"),
      ].join("-");
      if (!groupedByYearMonthDay[yearMonthDay]) {
        groupedByYearMonthDay[yearMonthDay] = [];
      }
      groupedByYearMonthDay[yearMonthDay].push(tweet);
    },
    console.error,
    dumpGroupedTwilogs
  );

function dumpGroupedTwilogs() {
  Object.entries(groupedByYearMonthDay).forEach(
    async ([yearMonthDay, twilogs]) => {
      const [year, month, day] = yearMonthDay.split("-");
      const dir = `data/${year}/${month}`;
      const file = `${dir}/${day}-twilogs.json`;
      await mkdir(dir, { recursive: true });
      if (existsSync(file)) {
        const currentData = JSON.parse(await readFile(file));
        const mergedData = twilogs
          .reduce((acc, twilog) => {
            // Update `acc` array element by `twilog` if it has the same `StatusId`, otherwise append `twilog` to `acc`
            const index = acc.findIndex((t) => t.StatusId === twilog.StatusId);
            if (index >= 0) {
              acc[index] = twilog;
            } else {
              acc.push(twilog);
            }
            return acc;
          }, currentData)
          .sort((a, b) => a.StatusId.localeCompare(b.StatusId))
          .map((twilog) => JSON.stringify(twilog))
          .join("\n,\n");
        console.log("Merging:", file);
        return writeFile(file, "[\n" + mergedData + "\n]\n");
      } else {
        const data = twilogs
          .sort((a, b) => a.StatusId.localeCompare(b.StatusId))
          .map((twilog) => JSON.stringify(twilog))
          .join("\n,\n");
        console.log("Writing:", file);
        return writeFile(file, "[\n" + data + "\n]\n");
      }
    }
  );
  console.log("Cursor:", cursor);
  writeFile("data/MY_TWILOGS_CSV_CURSOR", cursor.toString());
}
