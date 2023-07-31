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
  searchableAttributes: [
    "title",
    "authors",
    "seriesName",
    "volume",
    "label",
    "reviewMarkdown",
  ],
  attributesToRetrieve: [
    "id",
    "title",
    "authors",
    "img",
    "acquiredDate",
    "seriesName",
    "volume",
    "label",
    "reviewMarkdown",
  ],
  attributesToTransliterate: [
    "title",
    "authors",
    "seriesName",
    "volume",
    "label",
    "reviewMarkdown",
  ],
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
console.log("books", books.length);
const indexedIds = (
  await Promise.all(
    arrayChunks(
      books.map((book) => book.id),
      1000
    ).map(async (ids) => {
      return (await index.getObjects(ids)).results
        .filter((r) => r)
        .map((r) => r.objectID);
    })
  )
).flat();

console.log("indexed", indexedIds.length);
if (indexedIds.length === books.length) {
  console.log("No need to index");
  process.exit(0);
}

const toIndex = books.filter((book) => !indexedIds.includes(book.id));

await index.saveObjects(toIndex, { batchSize: 999999 });
console.log("Indexing requested", toIndex);

// Sanity check
const candidates = ["ヒストリエ", "宝石の国", "手塚治虫"];
testSearch(candidates[Math.floor(Math.random() * candidates.length)]);

async function testSearch(term) {
  const res = await index.search(term, { hitsPerPage: 3 });
  console.log("Search test", term, res.hits);
}

function arrayChunks(array, size) {
  const results = [];
  while (array.length) {
    results.push(array.splice(0, size));
  }
  return results;
}
