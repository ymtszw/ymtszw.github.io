/**
 * Must be run as: npm run import_twilogs <path-to-exported-twilogs-csv-file>
 *
 * This script imports Tweets from manually downloaded CSV file from Twilogs.
 * Twilogs CSV contains less information than Twitter-official archives,
 * so it tries to re-construct as much properties as possible.
 *
 */

import csv from "csvtojson";
import { existsSync } from "fs";
import { mkdir, readFile, readdir, writeFile } from "fs/promises";

// Do not overwrite Tweets fetched from Zapier since they have richer properties
const LAST_ID_FROM_ZAPIER_TWILOGS = "1701931660152041841";
const previousIdCursor = await readFile("data/TWILOGS_CSV_ID_CURSOR")
  .then((buf) => buf.toString().trim())
  .catch(() => LAST_ID_FROM_ZAPIER_TWILOGS);
let lastIdCursor = previousIdCursor;

const archiveFilePath = process.argv[2];
console.log(
  `Importing from ${archiveFilePath} down to last ID cursor: ${lastIdCursor}`
);

const groupedByYearMonthDay = {};
// Twilogs archive files are sorted from the LATEST to the oldest
csv({
  delimiter: ",",
  eol: "\n", // "Text" column contain breaks in the form of "\r\n", whereas the row breaks are always single "\n"
  noheader: true,
  headers: ["StatusId", "Url", "CreatedAt", "Text"],
})
  .fromFile(archiveFilePath)
  .subscribe(
    (tweet, lineNumber) => {
      if (tweet.StatusId <= previousIdCursor) {
        // Skip already imported twilogs
        return;
      } else if (tweet.StatusId > lastIdCursor) {
        // Update lastIdCursor (usually this happens only once, at the top of the file)
        lastIdCursor = tweet.StatusId;
        console.log(`Last ID cursor updated to ${lastIdCursor}`);
      } else {
        // Do nothing; just keep processing
      }

      const yearMonthDay = makeYearMonthDay(tweet.CreatedAt);
      if (!groupedByYearMonthDay[yearMonthDay]) {
        groupedByYearMonthDay[yearMonthDay] = [];
      }
      groupedByYearMonthDay[yearMonthDay].push(tweet);
    },
    console.error,
    dumpGroupedTwilogs
  );

function makeYearMonthDay(createdAt) {
  // TZ env var must be set. See package.json
  const ca = new Date(createdAt);
  return [
    ca.getFullYear(),
    (ca.getMonth() + 1).toString().padStart(2, "0"),
    ca.getDate().toString().padStart(2, "0"),
  ].join("-");
}

function dumpGroupedTwilogs() {
  Object.entries(groupedByYearMonthDay).forEach(
    async ([yearMonthDay, twilogs]) => {
      const [year, month, day] = yearMonthDay.split("-");
      const dir = `data/${year}/${month}`;
      const file = `${dir}/${day}-twilogs.json`;
      await mkdir(dir, { recursive: true });
      const sanitizedTwilogs = await Promise.all(twilogs.map(makeTwilogJson));
      if (existsSync(file)) {
        const currentData = JSON.parse(await readFile(file));
        const mergedData = sanitizedTwilogs
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
          .map(JSON.stringify)
          .join("\n,\n");
        console.log("Merging:", file);
        return writeFile(file, "[\n" + mergedData + "\n]\n");
      } else {
        const data = sanitizedTwilogs
          .sort((a, b) => a.StatusId.localeCompare(b.StatusId))
          .map(JSON.stringify)
          .join("\n,\n");
        console.log("Writing:", file);
        return writeFile(file, "[\n" + data + "\n]\n");
      }
    }
  );
  console.log("Writing updated ID cursor:", lastIdCursor);
  // writeFile("data/TWILOGS_CSV_ID_CURSOR", lastIdCursor);
  generateTwilogArchives();
}

const myAvatarUrl20230405 =
  "https://pbs.twimg.com/profile_images/1520432647868391430/4b2AUYjC_normal.jpg";

async function makeTwilogJson(tweetFromCsv) {
  // "StatusId", "Url", "CreatedAt", "Text"
  const retweetDetails = await extractRetweetDetails(tweetFromCsv);
  return {
    CreatedAt: new Date(tweetFromCsv.CreatedAt).toISOString(),
    Text: tweetFromCsv.Text.replaceAll("\r\n", "\n"),
    StatusId: tweetFromCsv.StatusId,
    UserName: "Gada / ymtszw",
    UserProfileImageUrl: myAvatarUrl20230405,
    ...retweetDetails,
  };
}

async function extractRetweetDetails(tweetFromCsv) {
  const url = new URL(tweetFromCsv.Url);
  // "/gada_twt/status/********************************" => ['', 'gada_twt', 'status', '********************************']
  const [_, screenName, _status, RetweetedStatusId] = url.pathname.split("/");
  const isRetweet = screenName !== "gada_twt";
  const userInfo = await resolveUserInfo(screenName);

  return {
    Retweet: isRetweet ? "TRUE" : "FALSE",
    RetweetedStatusId,
    RetweetedStatusFullText: isRetweet
      ? tweetFromCsv.Text.replaceAll("\r\n", "\n")
      : "",
    RetweetedStatusUserName: isRetweet ? userInfo.UserName : "",
    RetweetedStatusUserProfileImageUrl: isRetweet
      ? userInfo.UserProfileImageUrl
      : "",
  };
}

const resolvedUserInfoCache = {};
async function resolveUserInfo(screenName) {
  if (resolvedUserInfoCache[screenName]) {
    return resolvedUserInfoCache[screenName];
  } else {
    const profileUrl = `https://link-preview.ymtszw.workers.dev?q=https://twitter.com/${screenName}`;
    const metadata = await (await fetch(profileUrl)).json();
    const prefix = "Xユーザーの";
    const suffix = `（@${screenName}）さん`;
    const UserName = metadata.title?.replace(prefix, "").replace(suffix, "");
    const UserProfileImageUrl = metadata.image;
    const userInfo = { UserName, UserProfileImageUrl };
    resolvedUserInfoCache[screenName] = userInfo;
    return userInfo;
  }
}

export async function generateTwilogArchives() {
  const dataFiles = await readdir("data", { withFileTypes: true });
  const yearMonths = await Promise.all(
    dataFiles.map(async (dataFile) => {
      if (dataFile.isDirectory()) {
        const year = dataFile.name;
        const months = await readdir(`data/${year}`);
        return months.map((month) => `${year}-${month}`);
      } else {
        return [];
      }
    })
  );
  const yearMonthsFromNewest = yearMonths.flat().sort().reverse();

  return writeFile(
    "src/Generated/TwilogArchives.elm",
    `module Generated.TwilogArchives exposing (TwilogArchiveYearMonth, list)


type alias TwilogArchiveYearMonth =
    String


list : List TwilogArchiveYearMonth
list =
    [ ${yearMonthsFromNewest.map((a) => `"${a}"`).join("\n    , ")}
    ]
`
  );
}
