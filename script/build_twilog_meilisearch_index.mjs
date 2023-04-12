import { MeiliSearch, MeiliSearchApiError } from "meilisearch";
import { readFile } from "fs/promises";
import { eng, jpn } from "stopword";

const indexUid = "ymtszw-twilogs";

const client = new MeiliSearch({
  host: process.env.MEILISEARCH_HOST,
  apiKey: process.env.MEILISEARCH_ADMIN_KEY,
});

let index;
try {
  index = await client.getIndex(indexUid);
} catch (e) {
  if (e instanceof MeiliSearchApiError && e.httpStatus === 404) {
    index = await client.createIndex(indexUid, { primaryKey: "StatusId" });
  }
}

// 変更すると全体再indexが開始される
const updated = await index.updateSettings({
  pagination: { maxTotalHits: 30 },
  searchableAttributes: [
    "CreatedAt",
    "UserName",
    "Text",
    "RetweetedStatusUserName",
    "RetweetedStatusFullText",
    "QuotedStatusFullText",
  ],
  displayedAttributes: [
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
  filterableAttributes: [
    "CreatedAt",
    "UserName",
    "Text",
    "RetweetedStatusUserName",
    "RetweetedStatusFullText",
    "QuotedStatusFullText",
  ],
});
console.log("Index settings", updated);

const stopWords = [...eng, ...jpn];
console.log("Stop words", await index.updateStopWords(stopWords));

// Indexingは非同期で、裏でqueue管理される
process.argv.slice(2).forEach(async (changedArchivePath) => {
  const json = await readFile(changedArchivePath);
  const documents = JSON.parse(json);
  await index.addDocuments(documents);
  console.log("Indexing requested", changedArchivePath);
});

// Sanity check
const candidates = ["elm", "東京", "長野", "Siiibo"];
testSearch(candidates[Math.floor(Math.random() * candidates.length)]);

async function testSearch(term) {
  const res = await index.search(term, {
    limit: 3,
    attributesToHighlight: ["Text", "QuotedStatusFullText"],
    highlightPreTag: " **",
    highlightPostTag: "** ",
  });
  console.log(
    "Search test",
    term,
    res.hits.map((h) => h._formatted)
  );
}
