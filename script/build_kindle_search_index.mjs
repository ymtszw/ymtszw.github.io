import { algoliasearch } from "algoliasearch";
import fetch from "node-fetch";

const indexUid = "ymtszw-kindle";

const client = algoliasearch(
  process.env.ALGOLIA_APP_ID,
  process.env.ALGOLIA_ADMIN_KEY
);

// 変更すると全体再indexが開始される
const setResponse = await client.setSettings({
  indexName: indexUid,
  indexSettings: {
    paginationLimitedTo: 30,
    searchableAttributes: [
      "title",
      "rawTitle",
      "authors",
      "seriesName",
      "volume",
      "label",
      "reviewTitle",
      "reviewMarkdown",
    ],
    attributesToRetrieve: [
      "id",
      "title", // parse前
      "rawTitle", // parse後
      "authors",
      "img",
      "acquiredDate",
      "seriesName",
      "volume",
      "label",
      "reviewTitle",
      "reviewMarkdown",
      "reviewUpdatedAt",
      "reviewPublishedAt",
    ],
    attributesToTransliterate: [
      "title",
      "rawTitle",
      "authors",
      "seriesName",
      "volume",
      "label",
      "reviewTitle",
      "reviewMarkdown",
    ],
    indexLanguages: ["ja", "en"],
    queryLanguages: ["ja", "en"],
    removeStopWords: true,
  },
});
console.log("Index settings", setResponse);

// Gistから元データの一覧を取得する
const res = await fetch(process.env.BOOKS_JSON_URL);
const books = Object.values(await res.json()).map((book) => {
  return Object.assign(book, { objectID: book.id });
});
console.log("books", books.length);

// Algoliaからindex済みのID一覧を取得する
const indexedIds = (
  await Promise.all(
    arrayChunks(
      books.map((book) => {
        return { objectID: book.id, indexName: indexUid };
      }),
      1000
    ).map(async (requests) => {
      return (await client.getObjects({ requests: requests })).results
        .filter((r) => r)
        .map((r) => r.objectID);
    })
  )
).flat();

// 最新とIndex済みとで件数に差分がなければ終了
console.log("indexed", indexedIds.length);
if (indexedIds.length === books.length) {
  console.log("No need to index");
  process.exit(0);
}

// 差分があれば、Indexされていないものだけする
// Indexingは非同期で、裏でqueue管理される
const toIndex = books.filter((book) => !indexedIds.includes(book.id));
await client.saveObjects({
  indexName: indexUid,
  objects: toIndex,
  batchSize: 999999,
});
console.log("Indexing requested", toIndex);

// Sanity check
const candidates = ["ヒストリエ", "宝石の国", "手塚治虫"];
testSearch(candidates[Math.floor(Math.random() * candidates.length)]);

async function testSearch(term) {
  const res = await client.search({
    requests: [{ indexName: indexUid, query: term, hitsPerPage: 3 }],
  });
  console.log(
    "Search test",
    term,
    res.results.flatMap((r) => r.hits)
  );
}

function arrayChunks(array, size) {
  const results = [];
  while (array.length) {
    results.push(array.splice(0, size));
  }
  return results;
}
