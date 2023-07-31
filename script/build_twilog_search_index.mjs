import algoliasearch from "algoliasearch";
import { readFile } from "fs/promises";

const indexUid = "ymtszw-twilogs";

const client = algoliasearch(
  process.env.ALGOLIA_APP_ID,
  process.env.ALGOLIA_ADMIN_KEY
);

const index = client.initIndex(indexUid);

// 変更すると全体再indexが開始される
const setResponse = await index.setSettings({
  paginationLimitedTo: 30,
  searchableAttributes: [
    "CreatedAt",
    "UserName",
    "Text",
    "RetweetedStatusUserName",
    "RetweetedStatusFullText",
    "QuotedStatusFullText",
  ],
  attributesToRetrieve: [
    "StatusId",
    "CreatedAt",
    "UserName",
    "UserProfileImageUrl",
    "Text",
    "Retweet",
    "RetweetedStatusId",
    "RetweetedStatusFullText",
    "RetweetedStatusUserName",
    "RetweetedStatusUserProfileImageUrl",
    "QuotedStatusFullText",
  ],
  attributesToTransliterate: [
    "CreatedAt",
    "UserName",
    "Text",
    "RetweetedStatusUserName",
    "RetweetedStatusFullText",
    "QuotedStatusFullText",
  ],
  indexLanguages: ["ja", "en"],
  queryLanguages: ["ja", "en"],
  removeStopWords: true,
});
console.log("Index settings", setResponse);

// Indexingは非同期で、裏でqueue管理される
process.argv.slice(2).forEach(async (changedArchivePath) => {
  const json = await readFile(changedArchivePath);
  const documents = JSON.parse(json).map((d) => {
    return Object.assign(d, { objectID: d.StatusId });
  });
  await index.saveObjects(documents, { batchSize: 999999 });
  console.log("Indexing requested", changedArchivePath);
});

// Sanity check
const candidates = ["elm", "東京", "長野", "Siiibo"];
testSearch(candidates[Math.floor(Math.random() * candidates.length)]);

async function testSearch(term) {
  const res = await index.search(term, {
    hitsPerPage: 3,
  });
  console.log(
    "Search test",
    term,
    res.hits.map((h) => h.Text)
  );
}
