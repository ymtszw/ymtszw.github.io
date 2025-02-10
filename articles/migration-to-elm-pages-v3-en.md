---
title: "Migration from elm-pages v2 to v3"
description: |
  This article is a compilation of notes taken during the actual migration process, cleaned up and published after completing the migration of the entire codebase.
  How challenging is the migration to v3?
image: "/3.0en.png"
publishedAt: "2024-02-11T01:20:00+09:00"
---

For details, refer to the [**official upgrade documentation**](https://github.com/dillonkearns/elm-pages/blob/master/docs/3.0-upgrade-notes.md).

Basically, by following the official document, you should be able to modify your v2 repository to pass the v3 build. However, upgrade scripts are not provided, so manual work is required, and there are many pitfalls.

Dillon-san recommends creating a new repository using the [starter repo](https://github.com/dillonkearns/elm-pages-starter) as a template, ensuring it builds successfully, and then incrementally migrating the Page modules from the v2 repository while ensuring the build passes.

I followed this approach too and will highlight the key changes encountered. Specifically, this guide is intended for those who have **built static sites with v2 and want to migrate to v3 while keeping the site static.**
I believe this need is significant. At the end of the article, I will also touch on the development experience and build performance after migrating to v3.

(記事の日本語版は[こちら](/articles/migration-to-elm-pages-v3))

## Notable Preliminary Knowledge

- **Use of the [Lamdera compiler](https://lamdera.com/)**
  - It is an ["un-fork"](https://dashboard.lamdera.app/releases/open-source-compiler) of the Elm compiler, [promising future compatibility with the Elm compiler](https://dashboard.lamdera.app/docs/differences) while incorporating unique features.
  - It is now installed via NPM, so no special preparation to the local environment is necessary.
  - If using ElmLS, add workspace settings to use the Lamdera compiler:
    ```jsonc
    // Example of .vscode/settings.json
    "elmLS.elmPath": "node_modules/.bin/lamdera"
    ```
- **Use of Vite as the development tool**
  - `public/index.js` has been changed to `index.ts`, naturally supporting TypeScript via Vite.
  - By importing from this file, you can easily introduce other TypeScript files and NPM dependencies.
- The directory structure of the project has changed
  - The "Page" module has been renamed to "Route" (likely reflecting support for dynamic routes).
  - An `app/` directory has been added, where the implementation of the Route module is placed.
    - This structure follows the convention in several web frameworks where project-specific code (especially for file-based routing) is placed in the `app/` directory, while library-like code is placed in `src/` or `lib/`.
  - Thus, migration starts by copying `src/Page/Hoge.elm` to `app/Route/Hoge.elm`.

## Frequently Required Changes

- Change `Page.Hoge` to `Route.Hoge`.
- The auto-generated `Page` module has been changed to `RouteBuilder`.
  - Change `Page.prerender` to `RouteBuilder.preRender` (note the lowerCamelCase).
  - Change `Page.single` to `RouteBuilder.single`.
  - The auto-generated type names in `RouteBuilder` have also changed:
    - `Page.StaticPayload` is now `RouteBuilder.App`.
    - `Page.PageWithState` is now `RouteBuilder.StatefulRoute`.
  - Some APIs have changed in terms of the number and order of arguments, so adjust accordingly.
    - Generally, the `Data` type resolved by `BackendTask` is now at the beginning. Think of it as ordered from build-time-resolved to runtime-constructed.
- The Route module has additional required exports and some changes:
  - The `ActionData` type is now required (placeholder is `{}`).
  - The `page` function has been renamed to `route`.
  - Conversely, the `routes` function for `preRender` routes has been renamed to `pages`.
  - The placeholder for the `Model` type has changed from `()` to `{}`.
  - The placeholder for the `Msg` type has changed from `Never` to `()`.
- The `Path` module has been renamed to `UrlPath`.
- `DataSource` has evolved into `BackendTask`.
  - The mechanism for resolving data statically at build time remains, but error handling options have enriched, among other changes.
- The concept of `OptimizedDecoder` has been retired with the introduction of Lamdera, allowing the use of regular `Json.Decode`.
- The part where environment variables were incorporated using `Pages.Secrets` and used with `DataSource.Http` has evolved into `BackendTask.Env`.
- When issuing side effects from within the Route module, use `Effect` instead of bare `Cmd`.
  - Common intermediate layer patterns (cf. [elm-spa](https://www.elm-spa.dev/guide/03-pages#pageadvanced), [elm-land](https://elm.land/concepts/effect.html), [ConcourseCI](https://github.com/concourse/concourse/blob/master/web/elm/src/Message/Effects.elm)).
  - `Effect.elm` is in userland, so you can modify `Effect.perform` to add common side effects within the app.
  - `Browser.Navigation.Key` can only be used within `Effect.perform`, so side effects using `Browser.Navigation` that require the key should be implemented as `Effect`.
- The `Msg` concrete type in the `view` function of the Route module is now wrapped as `PagesMsg Msg`.
- The argument order of `Route.link` has changed:
  - ```elm
    -- v2
    Route.link Route.Index [ Attr.class "class" ] [ Html.text "child"]
    ```
  - ```elm
    -- v3
    Route.link [ Attr.class "class" ] [ Html.text "child"] Route.Index

    -- Probably to make it easier to write with Pipeline?
    Route.Index |> Route.link [ Attr.class "class" ] [ Html.text "child"]
    ```

## Pruning Features Not Required in Static Site Building

- Server rendering functionality has been added (using `RouteBuilder.serverRender` in the Route module), along with an adapter mechanism to connect to server-side implementations.
  - A reference implementation using Netlify Functions is provided.
  - To clean up if not using this, edit `elm-pages.config.mjs` to define a no-op adapter (empty adapter).
    - An example can be found in [this site's repository](https://github.com/ymtszw/ymtszw-v3/blob/master/elm-pages.config.mjs). The diff from the starter repo is:
      ```diff
      diff --git a/elm-pages.config.mjs b/elm-pages.config.mjs
      index 8982a8d..94c3c6c 100644
      --- a/elm-pages.config.mjs
      +++ b/elm-pages.config.mjs
      @@ -1,5 +1,4 @@
       import { defineConfig } from "vite";
      -import adapter from "elm-pages/adapter/netlify.js";

       export default {
         vite: defineConfig({}),
      @@ -16,3 +15,12 @@ export default {
           return !file.endsWith(".css");
         },
       };
      +
      +async function adapter({
      +  renderFunctionFilePath,
      +  routePatterns,
      +  apiRoutePatterns,
      +}) {
      +  console.log("Running empty adapter");
      +  return;
      +}
      ```
    - You can safely delete unnecessary files like `netlify.toml`.
    - The Netlify adapter reference implementation is included in elm-pages v3 and can be found at `node_modules/elm-pages/adapter/netlify.js`.
      - No files are generated in userland.
- A script mechanism has been introduced, and the scaffolding for new Routes is now provided from here (`npx elm-pages run AddRoute <route module name>`).
  - You can safely delete any example scripts provided in the starter repo that you don't plan to use.
  - Note that using the scaffolding script is not mandatory; you can simply duplicate existing Route files or start from an empty file, and running `elm-pages build` or starting the `elm-pages dev` server will generate the necessary code.
    - If required types or functions are missing, they will be detected as compile errors.
    - Customizing the scaffolding script requires delving into code generation, which is quite different from implementing a website with elm-pages, so it can lead to significant yak-shaving.
      - Once you have a few Route implementations with `RouteBuilder.single` and `RouteBuilder.preRender` and get used to it, I recommend just duplicating them for daily work.

## Undocumented Changes (So Far)

- The `init` function in the Route module no longer has runtime access to `Maybe PageUrl`.
  - Additionally, the `QueryParams` module is no longer provided.
  - However, `Shared.init` still has access to it.
  - Therefore, if you need runtime access to URL elements like query parameters, incorporate them into `Shared.Model` in `Shared.init` and `Shared.template.onPageChange`.
- (Related to the above,) clicking a link that changes only the query parameter or fragment within the same page no longer triggers the `init` function in the Route module.
  - As a result, it is difficult to change the UI state on the client side by holding state in query parameters or fragments. Depending on the functionality implemented in your v2 site, migration may not be possible.
    - Personally, I encountered this situation. I had implemented a Lightbox-style image viewer by holding information in the fragment and triggering a link, but it no longer worked.
  - Related issues: <https://github.com/dillonkearns/elm-pages/issues/479>, <https://github.com/dillonkearns/elm-pages/issues/509>
  - [Discussed on the issue](https://github.com/dillonkearns/elm-pages/issues/509#issuecomment-2639219898), but it is essentially a consideration oversight due to API redesign, and a new interface will likely be provided in the future.
    - However, it will not be in the form of re-calling `init`, but rather implementing a dedicated handler function. This respects existing code that assumes `init` is executed only once when entering a Route (i.e., non-idempotent).
- The format of embedded data files generated under `dist/` (i.e., data statically generated at build time for application initialization) has changed from `content.json` to binary `content.dat`.
  - The elm-pages runtime handles this, so we don't need to worry about it.

## Development Experience and Build Performance After Migrating to v3

- Vite is great
  - It makes it easy to introduce and bundle NPM dependencies, so having Vite as the foundation is quite helpful.
    - Personally, I realized I hadn't introduced Highlight.js, so I tried it, and it was very easy.
    - You can also optimize the runtime size of the build artifacts by using Vite's plugin ecosystem.
  - If you are already using Vite in another project and are familiar with it or have snippets, you can reuse them.
- The introduction of Lamdera and the associated API improvements are reasonable and not overly complex.
  - The change from `DataSource` to `BackendTask` should mostly be find-and-replaces.
  - The unification to `Json.Decode` by deprecating `OptimizedDecoder` is similarly straightforward and lowers the bar from a regular Elm app.
  - The abolition of `Pages.Secrets` and the transition to `BackendTask.Env` is intuitive and smooth if you are familiar with elm-pages v2.
- **Significant improvement in static build performance**
  - This was a major issue when generating a large number of pages from JSON files in v2.
  - It was likely due to the behavior around `OptimizedDecoder`, and generating several hundred files (i.e., pages) took [**about 6.5 minutes on CI**](https://github.com/ymtszw/ymtszw.github.io/actions/runs/13227746810/job/36920767626).
  - After migration, generating the same number of files took [**about 30 seconds**](https://github.com/ymtszw/ymtszw-v3/actions/runs/13228008829/job/36921331170).
    - This was a surprisingly significant improvement.
    - I had reported my experience with v2 to Dillon-san, and he had mentioned this as an expected improvement in v3, which turned out to be true.

## Unassessed Parts

- Server-Render Routes
  - Similar to pre-render, it triggers `BackendTask` to generate page content, but it does so dynamically at request time.
    - Following the trend of recent full-stack TypeScript frameworks.
  - Unlike static generation, it can depend on runtime data associated with the request (including headers like cookies or the body), allowing for pages that change display based on login status for instance.
  - It also enables building sites with a large amount of content that needs to be updated faster than the static build cycle of the site (e.g., news sites, e-commerce sites).
  - You can achieve the above without exposing APIs or secret information for data storage, and you can likely implement strategies to dynamically update edge caches based on the content returned by these routes.
  - This should become more important for business uses.
  - The reference implementation uses Netlify Functions, but [Netlify as a hosting environment is known to be slow from Japan](https://blog.anatoo.jp/2020-08-03), and this situation has not changed as of 2025.
    - Therefore, as a Japanese user, we would like to wait for the appearance of adapters implemented using Cloudflare Functions or Vercel. Also a good contribution opportunity!
    - Follow [this community discussion](https://github.com/dillonkearns/elm-pages/discussions/378).

## Conclusion: Should You Upgrade? / Time to Start?

Adding to all of the above, I recommend reading the [latest FAQ on elm-pages design](https://github.com/dillonkearns/elm-pages/blob/2cf36c670aafddd97f21171b1d0b9f7223eaaa1f/docs/FAQ.md) to deepen your understanding.

With all that in mind, should you invest the effort to upgrade? My personal evaluation is:

- **If your site (thus the necessary work) is relatively small, definitely do it**
  - Staying on v2 means no future feature additions and increasing hassle for deps updates to address security issues, so it's better to do it early.
  - The tips in this article for upgrading while keeping the site static might help.
- **If your site is already large but you are facing issues with build time, definitely do it**
  - This is one of the clear improvements in v3, so you will benefit from it.
  - Especially if you are doing it for work, reducing build time is a massive welfare.
- **If you rely heavily on client-side routing mechanisms for UI functionality, wait a bit**
  - URL transitions allow calling side effects while bypassing the boundaries of module structures/parent-child relationships in Elm apps, and I personally used this feature (or rather a loophole) quite a bit, so some features could not be upgraded.
  - Simple single-page features can be patched with `onClick`-triggered side effects, but features implemented in `Shared` and placed across multiple pages are challenging.

If you don't have a v2 site now and are interested in elm-pages? Now is **definitely the time to start**.

During the beta period and shortly after the release of elm-pages v3, there were difficulties with setting up the development environment, such as preparation of the Lamdera compiler, but these have been resolved, and you can develop just like a regular Elm project.

If you are not familiar with Elm, it is better to **learn the basics of Elm first** using the [famed Elm Guide](https://guide.elm-lang.org/) or find a mentor. However, if you are already familiar with Elm and want to build static sites in Elm or start full-stack Elm, it is an excellent choice.

Disclosure: [The author is a GitHub sponsor of Dillon-san, the creator of elm-pages](https://github.com/sponsors/dillonkearns).
