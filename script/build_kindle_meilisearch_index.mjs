import algoliasearch from "algoliasearch";
import fetch from "node-fetch";

const indexUid = "ymtszw-kindle";

const client = algoliasearch(
  process.env.ALGOLIA_APP_ID,
  process.env.ALGOLIA_ADMIN_KEY
);

const index = client.initIndex(indexUid);

// 変更すると全体再indexが開始される
const setResponse = await index.setSettings({
  paginationLimitedTo: 30,
  searchableAttributes: ["title", "authors"],
  attributesToRetrieve: ["id", "title", "authors", "img", "acquiredDate"],
  attributesToTransliterate: ["title", "authors"],
  indexLanguages: ["ja", "en"],
  queryLanguages: ["ja", "en"],
  removeStopWords: true,
});
console.log("Index settings", setResponse);

// Indexingは非同期で、裏でqueue管理される
const res = await fetch(process.env.BOOKS_JSON_URL);
const books = Object.values(await res.json()).map((book) => {
  return Object.assign(book, { objectID: book.id });
});
console.log("books", books.slice(0, 3));
await index.saveObjects(books, { batchSize: 999999 });
console.log("Indexing requested for books.json");

// Sanity check
const candidates = ["ヒストリエ", "宝石の国", "手塚治虫"];
testSearch(candidates[Math.floor(Math.random() * candidates.length)]);

async function testSearch(term) {
  const res = await index.search(term, { hitsPerPage: 3 });
  console.log("Search test", term, res.hits);
}
