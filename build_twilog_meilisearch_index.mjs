import { MeiliSearch, MeiliSearchApiError } from "meilisearch";
import { readFile } from "fs/promises";

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
    "UserName",
    "Text",
    "QuotedStatusFullText",
    "CreatedAt",
  ],
  displayedAttributes: [
    "StatusId",
    "UserName",
    "Text",
    "Retweet",
    "QuotedStatusFullText",
    "CreatedAt",
  ],
  filterableAttributes: [
    "UserName",
    "Text",
    "Retweet",
    "QuotedStatusFullText",
    "CreatedAt",
  ],
});
console.log("Index settings", updated);

// Indexingは非同期で、裏でqueue管理される
process.argv.slice(2).forEach(async (changedArchivePath) => {
  const json = await readFile(changedArchivePath);
  const documents = JSON.parse(json);
  await index.addDocuments(documents);
  console.log("Indexing requested", changedArchivePath);
});

// Sanity check
testSearch("elm");
testSearch("東京");
testSearch("長野");
testSearch("Siiibo");

async function testSearch(term) {
  const res = await index.search(term, {
    limit: 3,
    attributesToHighlight: ["Text", "QuotedStatusFullText"],
  });
  console.log(
    "Search test",
    term,
    res.hits.map((h) => h._formatted)
  );
}
