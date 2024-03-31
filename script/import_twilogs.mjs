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
const placeholderAvatarUrl =
  "https://abs.twimg.com/sticky/default_profile_images/default_profile_200x200.png";
async function makeTwilogJson(tweetFromCsv) {
  const url = new URL(tweetFromCsv.Url);
  // "/gada_twt/status/********************************" => ['', 'gada_twt', 'status', '********************************']
  const [_, screenName, _status, StatusId] = url.pathname.split("/");
  const isRetweet = screenName !== "gada_twt";
  const retweetDetails = await extractRetweetDetails(
    tweetFromCsv,
    isRetweet,
    screenName,
    StatusId
  );
  const urls = extractUrls(tweetFromCsv.Text, isRetweet);
  return {
    CreatedAt: new Date(tweetFromCsv.CreatedAt).toISOString(),
    Text: tweetFromCsv.Text.replaceAll("\r\n", "\n"),
    StatusId: tweetFromCsv.StatusId,
    UserName: "Gada / ymtszw",
    UserProfileImageUrl: myAvatarUrl20230405,
    ...retweetDetails,
    ...urls,
  };
}

async function extractRetweetDetails(
  tweetFromCsv,
  isRetweet,
  screenName,
  StatusId
) {
  let otherRetweetProps = {};
  if (isRetweet) {
    const userInfo = await resolveUserInfo(screenName);
    otherRetweetProps = {
      RetweetedStatusId: StatusId,
      RetweetedStatusFullText: tweetFromCsv.Text.replaceAll("\r\n", "\n"),
      RetweetedStatusUserName: userInfo.UserName,
      RetweetedStatusUserProfileImageUrl: userInfo.UserProfileImageUrl,
    };
  }

  return { Retweet: isRetweet ? "TRUE" : "FALSE", ...otherRetweetProps };
}

const resolvedUserInfoCache = {};
async function resolveUserInfo(screenName) {
  if (resolvedUserInfoCache[screenName]) {
    return resolvedUserInfoCache[screenName];
  } else {
    const profileUrl = `https://link-preview.ymtszw.workers.dev?q=https://twitter.com/${screenName}`;
    const metadata = await (await fetch(profileUrl)).json();
    const prefix = "Xユーザーの";
    const suffix = /（@.+）さん( \/ X)?/;
    const UserName = metadata.title?.replace(prefix, "").replace(suffix, "");
    const UserProfileImageUrl = metadata.image || placeholderAvatarUrl;
    const userInfo = { UserName, UserProfileImageUrl };
    resolvedUserInfoCache[screenName] = userInfo;
    return userInfo;
  }
}

/**
 * @param {string} text
 * @param {boolean} isRetweet
 */
function extractUrls(text, isRetweet) {
  const groups = { urls: [], media: [] };
  (text.match(new RegExp("https?://\\S+(?=\\s|$)", "g")) || []).forEach(
    (url) => {
      if (
        url.match(
          new RegExp("^https://twitter.com/[^/]+/status/[^/]+/photo/[^/]+$")
        )
      ) {
        groups.media.push({
          url,
          type: "photo",
          sourceUrl: "https://pbs.twimg.com/media/__NOT_LOADED__",
          expandedUrl: url,
        });
      } else {
        groups.urls.push(url);
      }
    }
  );
  return isRetweet
    ? {
        RetweetedStatusEntitiesUrlsUrls: groups.urls.join(",") || "",
        RetweetedStatusEntitiesUrlsExpandedUrls: groups.urls.join(",") || "",
        RetweetedStatusExtendedEntitiesMediaUrls:
          groups.media.map((m) => m.url).join(",") || "",
        RetweetedStatusExtendedEntitiesMediaTypes:
          groups.media.map((m) => m.type).join(",") || "",
        RetweetedStatusExtendedEntitiesMediaSourceUrls:
          groups.media.map((m) => m.sourceUrl).join(",") || "",
        RetweetedStatusExtendedEntitiesMediaExpandedUrls:
          groups.media.map((m) => m.expandedUrl).join(",") || "",
      }
    : {
        EntitiesUrlsUrls: groups.urls.join(",") || "",
        EntitiesUrlsExpandedUrls: groups.urls.join(",") || "",
        ExtendedEntitiesMediaUrls:
          groups.media.map((m) => m.url).join(",") || "",
        ExtendedEntitiesMediaTypes:
          groups.media.map((m) => m.type).join(",") || "",
        ExtendedEntitiesMediaSourceUrls:
          groups.media.map((m) => m.sourceUrl).join(",") || "",
        ExtendedEntitiesMediaExpandedUrls:
          groups.media.map((m) => m.expandedUrl).join(",") || "",
      };
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
