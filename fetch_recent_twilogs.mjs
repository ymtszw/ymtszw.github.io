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
import { mkdir, writeFile } from "fs/promises";
import { existsSync } from "fs";

let groupedByYearMonthDay = {};
const resp = await fetch(process.env.MY_TWILOG_CSV_URL);
csv({ delimiter: "," })
  .fromStream(resp.body)
  .subscribe(
    (tweet) => {
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
        // TODO: Merge smartly with existing file if they differ
        console.log("Already exists, skipping:", file);
        return 0;
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
}
