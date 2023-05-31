import { MeiliSearch, MeiliSearchApiError } from "meilisearch";
import { eng, jpn } from "stopword";
import fetch from "node-fetch";

const indexUid = "ymtszw-kindle";

const client = new MeiliSearch({
  host: process.env.MEILISEARCH_HOST,
  apiKey: process.env.MEILISEARCH_ADMIN_KEY,
});

let index;
try {
  index = await client.getIndex(indexUid);
} catch (e) {
  if (e instanceof MeiliSearchApiError && e.httpStatus === 404) {
    index = await client.createIndex(indexUid, { primaryKey: "id" });
  }
}

// 変更すると全体再indexが開始される
const updated = await index.updateSettings({
  pagination: { maxTotalHits: 30 },
  searchableAttributes: ["title", "authors"],
  displayedAttributes: ["id", "title", "authors", "img", "acquiredDate"],
  filterableAttributes: ["title", "authors", "acquiredDate"],
});
console.log("Index settings", updated);

const stopWords = [...eng, ...jpn];
console.log("Stop words", await index.updateStopWords(stopWords));

// Indexingは非同期で、裏でqueue管理される
const res = await fetch(process.env.BOOKS_JSON_URL);
const books = Object.values(await res.json());
console.log("books", books.slice(0, 3));
await index.addDocuments(books);
console.log("Indexing requested for books.json");

// Sanity check
const candidates = ["ヒストリエ", "宝石の国", "手塚治虫"];
testSearch(candidates[Math.floor(Math.random() * candidates.length)]);

async function testSearch(term) {
  const res = await index.search(term, { limit: 3 });
  console.log("Search test", term, res.hits);
}
