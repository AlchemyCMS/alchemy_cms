# Changelog

## 6.1.1 (2023-01-23)

- Re-introduce deleted methods [#2422](https://github.com/AlchemyCMS/alchemy_cms/pull/2422) ([tvdeyen](https://github.com/tvdeyen))
- Add searchable field to page (Alchemy 6.1) [#2420](https://github.com/AlchemyCMS/alchemy_cms/pull/2420) ([kulturbande](https://github.com/kulturbande))

## 6.1.0 (2023-01-19)

### Features

- Add page layouts repository class option [#2410](https://github.com/AlchemyCMS/alchemy_cms/pull/2410) ([tvdeyen](https://github.com/tvdeyen))
- Add element definitions repository class option [#2409](https://github.com/AlchemyCMS/alchemy_cms/pull/2409) ([tvdeyen](https://github.com/tvdeyen))
- Allow to set preview_sources [#2407](https://github.com/AlchemyCMS/alchemy_cms/pull/2407) ([tvdeyen](https://github.com/tvdeyen))
- Allow to add anchors to ingredients [#2395](https://github.com/AlchemyCMS/alchemy_cms/pull/2395) ([tvdeyen](https://github.com/tvdeyen))
- Add a error logger exception handler [#2387](https://github.com/AlchemyCMS/alchemy_cms/pull/2387) ([tvdeyen](https://github.com/tvdeyen))
- Add a element DOM id class [#2373](https://github.com/AlchemyCMS/alchemy_cms/pull/2373) ([tvdeyen](https://github.com/tvdeyen))

### Changes

- Remove old jasmine based javascript specs [#2400](https://github.com/AlchemyCMS/alchemy_cms/pull/2400) ([tvdeyen](https://github.com/tvdeyen))
- Update bundled Tinymce to 4.9.11 [#2399](https://github.com/AlchemyCMS/alchemy_cms/pull/2399) ([tvdeyen](https://github.com/tvdeyen))
- Add Headline size and level selects as input addons [#2398](https://github.com/AlchemyCMS/alchemy_cms/pull/2398) ([tvdeyen](https://github.com/tvdeyen))
- Remove Element.available scope [#2372](https://github.com/AlchemyCMS/alchemy_cms/pull/2372) ([tvdeyen](https://github.com/tvdeyen))
- Remove element_dom_id helper [#2369](https://github.com/AlchemyCMS/alchemy_cms/pull/2369) ([tvdeyen](https://github.com/tvdeyen))
- Use position for element dom_id [#2368](https://github.com/AlchemyCMS/alchemy_cms/pull/2368) ([tvdeyen](https://github.com/tvdeyen))
- Disallow deleting pages if still attached to menu node [#2338](https://github.com/AlchemyCMS/alchemy_cms/pull/2338) ([afdev82](https://github.com/afdev82))

### Fixes

- Add `:contact_form_id` to `messages` params in `messages_controller` [#2403](https://github.com/AlchemyCMS/alchemy_cms/pull/2403) ([chiperific](https://github.com/chiperific))
- Do not create thumbs for invalid pictures [#2386](https://github.com/AlchemyCMS/alchemy_cms/pull/2386) ([tvdeyen](https://github.com/tvdeyen))

### Misc

- [ruby - main] Upgrade sqlite3 to version 1.6.0 [#2408](https://github.com/AlchemyCMS/alchemy_cms/pull/2408) ([depfu](https://github.com/apps/depfu))
- [ruby - main] Upgrade puma to version 6.0.1 [#2404](https://github.com/AlchemyCMS/alchemy_cms/pull/2404) ([depfu](https://github.com/apps/depfu))
- CI: Update brakeman scan [#2390](https://github.com/AlchemyCMS/alchemy_cms/pull/2390) ([tvdeyen](https://github.com/tvdeyen))
- [ruby - main] Upgrade net-imap to version 0.3.1 [#2379](https://github.com/AlchemyCMS/alchemy_cms/pull/2379) ([depfu](https://github.com/apps/depfu))
- CI: Try ubuntu-latest [#2378](https://github.com/AlchemyCMS/alchemy_cms/pull/2378) ([tvdeyen](https://github.com/tvdeyen))
- [ruby - main] Upgrade sqlite3 to version 1.5.0 [#2374](https://github.com/AlchemyCMS/alchemy_cms/pull/2374) ([depfu](https://github.com/apps/depfu))
- [js] Upgrade babel-jest to version 29.0.1 [#2362](https://github.com/AlchemyCMS/alchemy_cms/pull/2362) ([depfu](https://github.com/apps/depfu))
- Use released Rails gems again for local testing [#2355](https://github.com/AlchemyCMS/alchemy_cms/pull/2355) ([tvdeyen](https://github.com/tvdeyen))
- [js] Upgrade babel-jest to version 28.0.2 [#2324](https://github.com/AlchemyCMS/alchemy_cms/pull/2324) ([depfu](https://github.com/apps/depfu))

## 6.0.12 (2022-11-19)

- More installer options [#2385](https://github.com/AlchemyCMS/alchemy_cms/pull/2385) ([tvdeyen](https://github.com/tvdeyen))
- Fix custom module installer [#2384](https://github.com/AlchemyCMS/alchemy_cms/pull/2384) ([tvdeyen](https://github.com/tvdeyen))
- Always provide format with attachment URLs [#2383](https://github.com/AlchemyCMS/alchemy_cms/pull/2383) ([mamhoff](https://github.com/mamhoff))

## 6.0.11 (2022-09-22)

- Do not touch pages when toggling element [#2377](https://github.com/AlchemyCMS/alchemy_cms/pull/2377) ([tvdeyen](https://github.com/tvdeyen))
- Remove unused Kaminari::Helpers::Tag hack [#2376](https://github.com/AlchemyCMS/alchemy_cms/pull/2376) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.10 (2022-09-04)

- Deprecate essence classes [#2371](https://github.com/AlchemyCMS/alchemy_cms/pull/2371) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate full_url_for_element helper [#2368](https://github.com/AlchemyCMS/alchemy_cms/pull/2368) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate element_dom_id helper [#2368](https://github.com/AlchemyCMS/alchemy_cms/pull/2368) ([tvdeyen](https://github.com/tvdeyen))
- Use position instead of id for element dom_id [#2368](https://github.com/AlchemyCMS/alchemy_cms/pull/2368) ([tvdeyen](https://github.com/tvdeyen))
- Fix ingredient boolean preview text [#2367](https://github.com/AlchemyCMS/alchemy_cms/pull/2367) ([tvdeyen](https://github.com/tvdeyen))
- Decide locale prefix with page language in show_alchemy_page_url helper [#2366](https://github.com/AlchemyCMS/alchemy_cms/pull/2366) ([tvdeyen](https://github.com/tvdeyen))
- Use cache_key_with_version in page_etag [#2365](https://github.com/AlchemyCMS/alchemy_cms/pull/2365) ([tvdeyen](https://github.com/tvdeyen))
- Fix author edit_content permissions [#2364](https://github.com/AlchemyCMS/alchemy_cms/pull/2364) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.9 (2022-07-25)

- Allow Site managers to remove page locks [#2360](https://github.com/AlchemyCMS/alchemy_cms/pull/2360) ([mamhoff](https://github.com/mamhoff))
- Add tags to Alchemy::EagerLoading [#2359](https://github.com/AlchemyCMS/alchemy_cms/pull/2359) ([mamhoff](https://github.com/mamhoff))
- Delete Gutentag Taggings in Alchemy::DeleteElements [#2358](https://github.com/AlchemyCMS/alchemy_cms/pull/2358) ([mamhoff](https://github.com/mamhoff))
- Fix PictureTransformations#inferred_sizes_from_string [#2356](https://github.com/AlchemyCMS/alchemy_cms/pull/2356) ([mamhoff](https://github.com/mamhoff))
- add playsinline attribute to ingredient and essence [#2351](https://github.com/AlchemyCMS/alchemy_cms/pull/2351) ([pascalbetz](https://github.com/pascalbetz))

## 6.0.8 (2022-06-10)

- Fix admin page tree links after update [#2348](https://github.com/AlchemyCMS/alchemy_cms/pull/2348) ([tvdeyen](https://github.com/tvdeyen))
- Fix initial selection of internal page link select [#2346](https://github.com/AlchemyCMS/alchemy_cms/pull/2346) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.7 (2022-06-04)

- Eagerly generate thumbs for srcset images in task as well [#2344](https://github.com/AlchemyCMS/alchemy_cms/pull/2344) ([tvdeyen](https://github.com/tvdeyen))
- Use HashWithIndifferentAccess for Page definition.  Key hint translation by page_layout [#2343](https://github.com/AlchemyCMS/alchemy_cms/pull/2343) ([dbwinger](https://github.com/dbwinger))

## 6.0.6 (2022-05-30)

- Add task to eagerly generate ingredients pictures thumbnails [#2342](https://github.com/AlchemyCMS/alchemy_cms/pull/2342) ([tvdeyen](https://github.com/tvdeyen))
- Add spec for ingredients migrator; fix preloading in Rails 6.1+ [#2340](https://github.com/AlchemyCMS/alchemy_cms/pull/2340) ([mamhoff](https://github.com/mamhoff))
- Extract element ingredient migrator [#2337](https://github.com/AlchemyCMS/alchemy_cms/pull/2337) ([tvdeyen](https://github.com/tvdeyen))
- Update published_at only after page has been published. [#2331](https://github.com/AlchemyCMS/alchemy_cms/pull/2331) ([pascalbetz](https://github.com/pascalbetz))
- Add element groups functionality for cleaning up editors [#2124](https://github.com/AlchemyCMS/alchemy_cms/pull/2124) ([dbwinger](https://github.com/dbwinger))
- Eagerload at the controller or job layer [#2313](https://github.com/AlchemyCMS/alchemy_cms/pull/2313) ([mamhoff](https://github.com/mamhoff))

## 6.0.5 (2022-05-11)

- Extract element ingredient migrator [#2337](https://github.com/AlchemyCMS/alchemy_cms/pull/2337) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.4 (2022-05-06)

- Add support for Rails' recycable cache keys [#2334](https://github.com/AlchemyCMS/alchemy_cms/pull/2334) ([tvdeyen](https://github.com/tvdeyen))
- Make Alchemy::Content::Factory reloadable [#2333](https://github.com/AlchemyCMS/alchemy_cms/pull/2333) ([tvdeyen](https://github.com/tvdeyen))
- Wrap the result of rendering into an ActiveSupport::SafeBuffer [#2332](https://github.com/AlchemyCMS/alchemy_cms/pull/2332) ([mamhoff](https://github.com/mamhoff))
- Override Alchemy::Page.ransackable_scopes [#2328](https://github.com/AlchemyCMS/alchemy_cms/pull/2328) ([mamhoff](https://github.com/mamhoff))
- Default Link Format matcher: Allow tel: protocol [#2327](https://github.com/AlchemyCMS/alchemy_cms/pull/2327) ([mamhoff](https://github.com/mamhoff))

## 6.0.3 (2022-05-02)

- Add Support for MariaDB [#2326](https://github.com/AlchemyCMS/alchemy_cms/pull/2326) ([mamhoff](https://github.com/mamhoff))
- Fix Alchemy::Content::Factory module definition [#2325](https://github.com/AlchemyCMS/alchemy_cms/pull/2325) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.2 (2022-04-27)

- Remove JSON decode from ingredient data store [#2323](https://github.com/AlchemyCMS/alchemy_cms/pull/2323) ([tvdeyen](https://github.com/tvdeyen))
- Eagerload at the controller or job layer [#2313](https://github.com/AlchemyCMS/alchemy_cms/pull/2313) ([mamhoff](https://github.com/mamhoff))

## 6.0.1 (2022-04-26)

- Allow passing a different partial to `render_element` [#2322](https://github.com/AlchemyCMS/alchemy_cms/pull/2322) ([mamhoff](https://github.com/mamhoff))
- Allow render_elements to take a block [#2321](https://github.com/AlchemyCMS/alchemy_cms/pull/2321) ([mamhoff](https://github.com/mamhoff))
- Remove old unused root_page ivar [#2320](https://github.com/AlchemyCMS/alchemy_cms/pull/2320) ([tvdeyen](https://github.com/tvdeyen))
- Raise on non-existing locale [#2319](https://github.com/AlchemyCMS/alchemy_cms/pull/2319) ([mamhoff](https://github.com/mamhoff))
- chore: Remove unnecessary puts from spec [#2318](https://github.com/AlchemyCMS/alchemy_cms/pull/2318) ([tvdeyen](https://github.com/tvdeyen))
- Fix gif resizing [#2315](https://github.com/AlchemyCMS/alchemy_cms/pull/2315) ([kulturbande](https://github.com/kulturbande))
- Refactor: Use page version's element repository rather than a new one [#2312](https://github.com/AlchemyCMS/alchemy_cms/pull/2312) ([mamhoff](https://github.com/mamhoff))
- Deprecate Alchemy::Element.available [#2309](https://github.com/AlchemyCMS/alchemy_cms/pull/2309) ([mamhoff](https://github.com/mamhoff))
- Explicitly set "store" for MariaDB [#2308](https://github.com/AlchemyCMS/alchemy_cms/pull/2308) ([mamhoff](https://github.com/mamhoff))
- Set preview mode earlier [#2307](https://github.com/AlchemyCMS/alchemy_cms/pull/2307) ([mamhoff](https://github.com/mamhoff))
- Fix updating the public_on date on persisted pages [#2305](https://github.com/AlchemyCMS/alchemy_cms/pull/2305) ([mamhoff](https://github.com/mamhoff))
- Allow opting out of Turbolinks in non-Alchemy controllers [#2302](https://github.com/AlchemyCMS/alchemy_cms/pull/2302) ([dssjoblom](https://github.com/dssjoblom))
- Explicitly validate uniqueness without case sensitivity [#2300](https://github.com/AlchemyCMS/alchemy_cms/pull/2300) ([mamhoff](https://github.com/mamhoff))
- Fix frozen string error when mixing template engines [#2299](https://github.com/AlchemyCMS/alchemy_cms/pull/2299) ([gr8bit](https://github.com/gr8bit))
- Do not flatten gifs if converted to webp [#2293](https://github.com/AlchemyCMS/alchemy_cms/pull/2293) ([tvdeyen](https://github.com/tvdeyen))
- Allow pasting into parent element with only one nested element type [#2292](https://github.com/AlchemyCMS/alchemy_cms/pull/2292) ([dbwinger](https://github.com/dbwinger))
- Restrict Node select to the site/language of the page being edited [#2277](https://github.com/AlchemyCMS/alchemy_cms/pull/2277) ([dbwinger](https://github.com/dbwinger))
- Add Ruby 3.1 support [#2229](https://github.com/AlchemyCMS/alchemy_cms/pull/2229) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.0 (2022-04-11)

- [ruby - main] Allow ransack version 3.0.1 [#2287](https://github.com/AlchemyCMS/alchemy_cms/pull/2287) ([depfu](https://github.com/apps/depfu))
- Fix image loader [#2285](https://github.com/AlchemyCMS/alchemy_cms/pull/2285) ([tvdeyen](https://github.com/tvdeyen))
- Don't delete locals in render_element so they can be used by all elements in render_elements [#2283](https://github.com/AlchemyCMS/alchemy_cms/pull/2283) ([dbwinger](https://github.com/dbwinger))
- Don't hardcode URLs in Javascript  [#2282](https://github.com/AlchemyCMS/alchemy_cms/pull/2282) ([dssjoblom](https://github.com/dssjoblom))
- [ruby - main] Allow ransack 3.0.0 [#2278](https://github.com/AlchemyCMS/alchemy_cms/pull/2278) ([depfu](https://github.com/apps/depfu))
- Show site and language name on page select in Link dialog [#2276](https://github.com/AlchemyCMS/alchemy_cms/pull/2276) ([dbwinger](https://github.com/dbwinger))
- Allow webp as image file format [#2274](https://github.com/AlchemyCMS/alchemy_cms/pull/2274) ([tvdeyen](https://github.com/tvdeyen))
- Rails 7 Support [#2225](https://github.com/AlchemyCMS/alchemy_cms/pull/2225) ([tvdeyen](https://github.com/tvdeyen))
- Support AR enums in resource models [#2210](https://github.com/AlchemyCMS/alchemy_cms/pull/2210) ([robinboening](https://github.com/robinboening))

## 6.0.0-rc7 (2022-03-28)

- fix(Sitemap): Use response data [#2272](https://github.com/AlchemyCMS/alchemy_cms/pull/2272) ([tvdeyen](https://github.com/tvdeyen))
- Revert "Ajax: Send method override" [#2271](https://github.com/AlchemyCMS/alchemy_cms/pull/2271) ([tvdeyen](https://github.com/tvdeyen))
- ImageLoader: Add error handling [#2270](https://github.com/AlchemyCMS/alchemy_cms/pull/2270) ([tvdeyen](https://github.com/tvdeyen))
- Check presence of page_public checkbox [#2269](https://github.com/AlchemyCMS/alchemy_cms/pull/2269) ([afdev82](https://github.com/afdev82))
- Use lodash-es instead of lodash [#2268](https://github.com/AlchemyCMS/alchemy_cms/pull/2268) ([afdev82](https://github.com/afdev82))
- CI: Update stale workflow [#2267](https://github.com/AlchemyCMS/alchemy_cms/pull/2267) ([tvdeyen](https://github.com/tvdeyen))
- Allow to skip db:create during install task [#2266](https://github.com/AlchemyCMS/alchemy_cms/pull/2266) ([tvdeyen](https://github.com/tvdeyen))
- CI: Fix mysql builds [#2263](https://github.com/AlchemyCMS/alchemy_cms/pull/2263) ([tvdeyen](https://github.com/tvdeyen))
- Fix new Sitemap [#2262](https://github.com/AlchemyCMS/alchemy_cms/pull/2262) ([tvdeyen](https://github.com/tvdeyen))
- [ruby - main] Allow ransack version 2.6.0 [#2259](https://github.com/AlchemyCMS/alchemy_cms/pull/2259) ([depfu](https://github.com/apps/depfu))
- Allow all pages in API again [#2258](https://github.com/AlchemyCMS/alchemy_cms/pull/2258) ([tvdeyen](https://github.com/tvdeyen))
- Fix setting default value of ingredients [#2257](https://github.com/AlchemyCMS/alchemy_cms/pull/2257) ([tvdeyen](https://github.com/tvdeyen))
- Eager load in PageTree serializer [#2256](https://github.com/AlchemyCMS/alchemy_cms/pull/2256) ([tvdeyen](https://github.com/tvdeyen))
- Revert "Merge pull request #2203 from tvdeyen/switch-to-cuprite" [#2255](https://github.com/AlchemyCMS/alchemy_cms/pull/2255) ([tvdeyen](https://github.com/tvdeyen))
- [js] New version of flatpickr (4.6.10) broke the build [#2254](https://github.com/AlchemyCMS/alchemy_cms/pull/2254) ([depfu](https://github.com/apps/depfu))
- New sortable page tree [#2252](https://github.com/AlchemyCMS/alchemy_cms/pull/2252) ([tvdeyen](https://github.com/tvdeyen))
- Use minor versions for ruby version matrix [#2251](https://github.com/AlchemyCMS/alchemy_cms/pull/2251) ([tvdeyen](https://github.com/tvdeyen))
- Precompile packs during test setup [#2250](https://github.com/AlchemyCMS/alchemy_cms/pull/2250) ([tvdeyen](https://github.com/tvdeyen))
- Allow parent page change [#2246](https://github.com/AlchemyCMS/alchemy_cms/pull/2246) ([tvdeyen](https://github.com/tvdeyen))
- Send language_id to Api::PagesController#index so Pages can be restricted to the language of the page [#2245](https://github.com/AlchemyCMS/alchemy_cms/pull/2245) ([dbwinger](https://github.com/dbwinger))

## 6.0.0-rc6 (2022-03-05)

- Rework sitemap JS [#2249](https://github.com/AlchemyCMS/alchemy_cms/pull/2249) ([tvdeyen](https://github.com/tvdeyen))
- Remove old page layout change code from update action [#2248](https://github.com/AlchemyCMS/alchemy_cms/pull/2248) ([tvdeyen](https://github.com/tvdeyen))
- Fix rendering errors in page configure overlay [#2247](https://github.com/AlchemyCMS/alchemy_cms/pull/2247) ([tvdeyen](https://github.com/tvdeyen))
- Fix copying page with descendants to a different language [#2243](https://github.com/AlchemyCMS/alchemy_cms/pull/2243) ([dbwinger](https://github.com/dbwinger))
- Handle copying/pasting global pages [#2241](https://github.com/AlchemyCMS/alchemy_cms/pull/2241) ([dbwinger](https://github.com/dbwinger))

## 6.0.0-rc5 (2022-02-24)

### Changes

- Change database version to 6.0 [#2239](https://github.com/AlchemyCMS/alchemy_cms/pull/2239) ([tvdeyen](https://github.com/tvdeyen))
- Remove unused route [#2238](https://github.com/AlchemyCMS/alchemy_cms/pull/2238) ([phantomwhale](https://github.com/phantomwhale))
- Add custom gutentag tag validations class [#2232](https://github.com/AlchemyCMS/alchemy_cms/pull/2232) ([tvdeyen](https://github.com/tvdeyen))
- Touch nodes and all ancestors on page update [#2226](https://github.com/AlchemyCMS/alchemy_cms/pull/2226) ([tvdeyen](https://github.com/tvdeyen))
- Extract Airbrake error handler into extension [#2221](https://github.com/AlchemyCMS/alchemy_cms/pull/2221) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.0-rc4 (2022-01-16)

### Changes

- Allow ransack 2.5.0 [#2223](https://github.com/AlchemyCMS/alchemy_cms/pull/2223) ([depfu](https://github.com/apps/depfu))
- make the admin error tracker customizable [#2220](https://github.com/AlchemyCMS/alchemy_cms/pull/2220) ([DarkSwoop](https://github.com/DarkSwoop))
- Update Flatpickr to 4.6.9 [#2197](https://github.com/AlchemyCMS/alchemy_cms/pull/2197) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.0-rc3 (2021-11-24)

### Changes

- Set stampable user_class_name without root identifier [#2215](https://github.com/AlchemyCMS/alchemy_cms/pull/2215) ([tvdeyen](https://github.com/tvdeyen))
- Allow all possible args in tagged_with method [#2211](https://github.com/AlchemyCMS/alchemy_cms/pull/2211) ([robinboening](https://github.com/robinboening))

### Fixes

- fix(ImageCropper): Add dom ids to picture crop fields [#2219](https://github.com/AlchemyCMS/alchemy_cms/pull/2219) ([tvdeyen](https://github.com/tvdeyen))
- Adjust tinymce skin assets urls again [#2218](https://github.com/AlchemyCMS/alchemy_cms/pull/2218) ([tvdeyen](https://github.com/tvdeyen))
- Use relative path for tinymce font-face [#2214](https://github.com/AlchemyCMS/alchemy_cms/pull/2214) ([tvdeyen](https://github.com/tvdeyen))

### Misc

- Install correct npm package [#2204](https://github.com/AlchemyCMS/alchemy_cms/pull/2204) ([tvdeyen](https://github.com/tvdeyen))
- Switch to cuprite for system testing [#2203](https://github.com/AlchemyCMS/alchemy_cms/pull/2203) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade webdrivers to version 5.0.0 [#2201](https://github.com/AlchemyCMS/alchemy_cms/pull/2201) ([depfu](https://github.com/apps/depfu))

## 6.0.0-rc2 (2021-10-13)

- Fix init link dialog if used in tinymce [#2200](https://github.com/AlchemyCMS/alchemy_cms/pull/2200) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.0-rc1 (2021-09-12)

- Allow Rails 6.1 [#2047](https://github.com/AlchemyCMS/alchemy_cms/pull/2047) ([robinboening](https://github.com/robinboening))

## 6.0.0-b6 (2021-09-02)

- Fix element with ingredients preview text [#2187](https://github.com/AlchemyCMS/alchemy_cms/pull/2187) ([tvdeyen](https://github.com/tvdeyen))
- Do not validate element during toggle fold and create [#2186](https://github.com/AlchemyCMS/alchemy_cms/pull/2186) ([tvdeyen](https://github.com/tvdeyen))
## 6.0.0-b5 (2021-08-27)

- Remove spec that tests default data store value [#2184](https://github.com/AlchemyCMS/alchemy_cms/pull/2184) ([tvdeyen](https://github.com/tvdeyen))
- Remove data store accessor from ingredient base class [#2183](https://github.com/AlchemyCMS/alchemy_cms/pull/2183) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.0-b4 (2021-08-27)

- Load custom Tinymce config for ingredients [#2182](https://github.com/AlchemyCMS/alchemy_cms/pull/2182) ([tvdeyen](https://github.com/tvdeyen))
- Fix ingredient editor selector in element update callback [#2181](https://github.com/AlchemyCMS/alchemy_cms/pull/2181) ([tvdeyen](https://github.com/tvdeyen))
- Ingredient by role block level helper [#2180](https://github.com/AlchemyCMS/alchemy_cms/pull/2180) ([tvdeyen](https://github.com/tvdeyen))
- Fixes caching [#2179](https://github.com/AlchemyCMS/alchemy_cms/pull/2179) ([tvdeyen](https://github.com/tvdeyen))
- make images non-executable [#2176](https://github.com/AlchemyCMS/alchemy_cms/pull/2176) ([mensfeld](https://github.com/mensfeld))
- Release task [#2173](https://github.com/AlchemyCMS/alchemy_cms/pull/2173) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.0.b3 (2021-08-12)

### Fixes

- Simplify ingredient creation [#2171](https://github.com/AlchemyCMS/alchemy_cms/pull/2171) ([tvdeyen](https://github.com/tvdeyen))
- Return ingredients value if element asked for ingredient [#2170](https://github.com/AlchemyCMS/alchemy_cms/pull/2170) ([tvdeyen](https://github.com/tvdeyen))
- Fix ingredient form field DOM ids [#2167](https://github.com/AlchemyCMS/alchemy_cms/pull/2167) ([tvdeyen](https://github.com/tvdeyen))
- Ensure resource table ends before the filter/tag sidebar [#2166](https://github.com/AlchemyCMS/alchemy_cms/pull/2166) ([robinboening](https://github.com/robinboening))
- Return fully namespaced ingredient constant [#2164](https://github.com/AlchemyCMS/alchemy_cms/pull/2164) ([tvdeyen](https://github.com/tvdeyen))
- (Re)-init Tinymce for elements with ingredients [#2163](https://github.com/AlchemyCMS/alchemy_cms/pull/2163) ([tvdeyen](https://github.com/tvdeyen))

## 6.0.0.b2 (2021-08-05)

### Features

- Add datepicker simple form input [#2162](https://github.com/AlchemyCMS/alchemy_cms/pull/2162) ([tvdeyen](https://github.com/tvdeyen))
- Feature flexible resource filters [#2091](https://github.com/AlchemyCMS/alchemy_cms/pull/2091) ([robinboening](https://github.com/robinboening))

### Changes

- Require alchemy/version [#2159](https://github.com/AlchemyCMS/alchemy_cms/pull/2159) ([tvdeyen](https://github.com/tvdeyen))
- Make ingredient examples usable without elements.yml [#2158](https://github.com/AlchemyCMS/alchemy_cms/pull/2158) ([tvdeyen](https://github.com/tvdeyen))
- Fix ingredient migrator (again) [#2155](https://github.com/AlchemyCMS/alchemy_cms/pull/2155) ([tvdeyen](https://github.com/tvdeyen))
- Respect additional essence attributes during ingredients migration [#2154](https://github.com/AlchemyCMS/alchemy_cms/pull/2154) ([tvdeyen](https://github.com/tvdeyen))
- Improve cache key defaults for menus [#2153](https://github.com/AlchemyCMS/alchemy_cms/pull/2153) ([oneiros](https://github.com/oneiros))
- Make element preview text work with ingredients [#2152](https://github.com/AlchemyCMS/alchemy_cms/pull/2152) ([tvdeyen](https://github.com/tvdeyen))
- Do not leak all records for guest users in API controllers [#2145](https://github.com/AlchemyCMS/alchemy_cms/pull/2145) ([tvdeyen](https://github.com/tvdeyen))

### Misc

- [ruby - main] Upgrade shoulda-matchers to version 5.0.0 [#2161](https://github.com/AlchemyCMS/alchemy_cms/pull/2161) ([depfu](https://github.com/apps/depfu))

## 6.0.0.b1 (2021-07-05)

### Features

- Import essence video and audio from extension [#2089](https://github.com/AlchemyCMS/alchemy_cms/pull/2089) ([tvdeyen](https://github.com/tvdeyen))
- Introduce ingredients as new content structure [#2061](https://github.com/AlchemyCMS/alchemy_cms/pull/2061) ([tvdeyen](https://github.com/tvdeyen))
- Alchemy essence headline [#2060](https://github.com/AlchemyCMS/alchemy_cms/pull/2060) ([mamhoff](https://github.com/mamhoff))
- Add Page Versions [#2022](https://github.com/AlchemyCMS/alchemy_cms/pull/2022) ([tvdeyen](https://github.com/tvdeyen))

### Changes

- Link dialog changes can be submitted by enter [#2144](https://github.com/AlchemyCMS/alchemy_cms/pull/2144) ([tvdeyen](https://github.com/tvdeyen))
- Extract Thumbnails and CropAction concerns [#2141](https://github.com/AlchemyCMS/alchemy_cms/pull/2141) ([tvdeyen](https://github.com/tvdeyen))
- generate picture thumbnails only for pictures with convertible format [#2129](https://github.com/AlchemyCMS/alchemy_cms/pull/2129) ([afdev82](https://github.com/afdev82))
- Only crop image if cropping is enabled [#2143](https://github.com/AlchemyCMS/alchemy_cms/pull/2143) ([tvdeyen](https://github.com/tvdeyen))
- expose translations in global Alchemy js object, #2113 [#2114](https://github.com/AlchemyCMS/alchemy_cms/pull/2114) ([afdev82](https://github.com/afdev82))
- Only return pages for current site in API [#2111](https://github.com/AlchemyCMS/alchemy_cms/pull/2111) ([tvdeyen](https://github.com/tvdeyen))
- Add crop_resize Dragonfly processor [#2109](https://github.com/AlchemyCMS/alchemy_cms/pull/2109) ([tvdeyen](https://github.com/tvdeyen))
- Auto-orient images based on their EXIF data [#2107](https://github.com/AlchemyCMS/alchemy_cms/pull/2107) ([tvdeyen](https://github.com/tvdeyen))
- Allow flatten as argument for Dragonfly encode [#2106](https://github.com/AlchemyCMS/alchemy_cms/pull/2106) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate image format methods [#2103](https://github.com/AlchemyCMS/alchemy_cms/pull/2103) ([tvdeyen](https://github.com/tvdeyen))
- Do not attempt to generate thumbs for svg files (fixes upload of svg files) [#2090](https://github.com/AlchemyCMS/alchemy_cms/pull/2090) ([oneiros](https://github.com/oneiros))
- Trigger publish targets after page published [#2088](https://github.com/AlchemyCMS/alchemy_cms/pull/2088) ([tvdeyen](https://github.com/tvdeyen))
- Add collection option for resource relations [#2084](https://github.com/AlchemyCMS/alchemy_cms/pull/2084) ([robinboening](https://github.com/robinboening))
- Remove deprecated helper method page_active? [#2074](https://github.com/AlchemyCMS/alchemy_cms/pull/2074) ([robinboening](https://github.com/robinboening))
- Handle json requests in error handler [#2071](https://github.com/AlchemyCMS/alchemy_cms/pull/2071) ([tvdeyen](https://github.com/tvdeyen))
- Background page publishing [#2067](https://github.com/AlchemyCMS/alchemy_cms/pull/2067) ([tvdeyen](https://github.com/tvdeyen))
- Faster element duplication [#2066](https://github.com/AlchemyCMS/alchemy_cms/pull/2066) ([mamhoff](https://github.com/mamhoff))
- Parse params in ajax.get as query string [#2070](https://github.com/AlchemyCMS/alchemy_cms/pull/2070) ([tvdeyen](https://github.com/tvdeyen))
- Assign, crop and remove files and pictures client side [#2069](https://github.com/AlchemyCMS/alchemy_cms/pull/2069) ([tvdeyen](https://github.com/tvdeyen))
- Allow copying contents when they're not in the elements.yml [#2068](https://github.com/AlchemyCMS/alchemy_cms/pull/2068) ([mamhoff](https://github.com/mamhoff))
- Delete nested elements quickly [#2065](https://github.com/AlchemyCMS/alchemy_cms/pull/2065) ([mamhoff](https://github.com/mamhoff))
- Quickly delete elements when deleting a page version [#2064](https://github.com/AlchemyCMS/alchemy_cms/pull/2064) ([mamhoff](https://github.com/mamhoff))
- Fast element deletion [#2063](https://github.com/AlchemyCMS/alchemy_cms/pull/2063) ([mamhoff](https://github.com/mamhoff))
- Touch Elements only after update [#2062](https://github.com/AlchemyCMS/alchemy_cms/pull/2062) ([mamhoff](https://github.com/mamhoff))
- Convert "Visit page" button to "Link to new tab" [#2058](https://github.com/AlchemyCMS/alchemy_cms/pull/2058) ([mamhoff](https://github.com/mamhoff))
- Allow creating an EssenceRichtext without a content [#2057](https://github.com/AlchemyCMS/alchemy_cms/pull/2057) ([mamhoff](https://github.com/mamhoff))
- Allow instantiating a content on an unpersisted valid element [#2056](https://github.com/AlchemyCMS/alchemy_cms/pull/2056) ([mamhoff](https://github.com/mamhoff))
- Sanitized richtext body [#2055](https://github.com/AlchemyCMS/alchemy_cms/pull/2055) ([mamhoff](https://github.com/mamhoff))
- Only require the Rails gems we actually need [#2054](https://github.com/AlchemyCMS/alchemy_cms/pull/2054) ([tvdeyen](https://github.com/tvdeyen))
- Create new contents on demand [#2049](https://github.com/AlchemyCMS/alchemy_cms/pull/2049) ([tvdeyen](https://github.com/tvdeyen))
- Add Elements repository [#2039](https://github.com/AlchemyCMS/alchemy_cms/pull/2039) ([tvdeyen](https://github.com/tvdeyen))
- Render site layout with block [#2038](https://github.com/AlchemyCMS/alchemy_cms/pull/2038) ([henvo](https://github.com/henvo))
- Add namespace for Tree related routes [#2037](https://github.com/AlchemyCMS/alchemy_cms/pull/2037) ([dhiraj14](https://github.com/dhiraj14))
- Tidy Rake task to remove duplicate legacy URLs [#2036](https://github.com/AlchemyCMS/alchemy_cms/pull/2036) ([pelargir](https://github.com/pelargir))
- Change Factory loading mechanism to FactoryBots supported mechanism [#2029](https://github.com/AlchemyCMS/alchemy_cms/pull/2029) ([mamhoff](https://github.com/mamhoff))
- Add rake task to remove trashed elements [#2025](https://github.com/AlchemyCMS/alchemy_cms/pull/2025) ([tvdeyen](https://github.com/tvdeyen))
- Do not include unpublished pages in breadcrumb [#2020](https://github.com/AlchemyCMS/alchemy_cms/pull/2020) ([tvdeyen](https://github.com/tvdeyen))
- Respect Language public status for page public status [#2017](https://github.com/AlchemyCMS/alchemy_cms/pull/2017) ([tvdeyen](https://github.com/tvdeyen))
- Use at least Ruby 2.5 [#2014](https://github.com/AlchemyCMS/alchemy_cms/pull/2014) ([tvdeyen](https://github.com/tvdeyen))
- Drop Rails 5.2 support [#2013](https://github.com/AlchemyCMS/alchemy_cms/pull/2013) ([tvdeyen](https://github.com/tvdeyen))
- Remove page layout change of persisted pages [#1991](https://github.com/AlchemyCMS/alchemy_cms/pull/1991) ([tvdeyen](https://github.com/tvdeyen))
- Remove element trash [#1987](https://github.com/AlchemyCMS/alchemy_cms/pull/1987) ([tvdeyen](https://github.com/tvdeyen))
- Remove elements fallbacks [#1983](https://github.com/AlchemyCMS/alchemy_cms/pull/1983) ([tvdeyen](https://github.com/tvdeyen))

### Misc

- Fixes i18n Jest specs [#2120](https://github.com/AlchemyCMS/alchemy_cms/pull/2120) ([tvdeyen](https://github.com/tvdeyen))
- Allow to update element without tags [#2150](https://github.com/AlchemyCMS/alchemy_cms/pull/2150) ([tvdeyen](https://github.com/tvdeyen))
- fix: call paging on jquery tabs only after initializing them [#2146](https://github.com/AlchemyCMS/alchemy_cms/pull/2146) ([robinboening](https://github.com/robinboening))
- Image cropper destroy [#2139](https://github.com/AlchemyCMS/alchemy_cms/pull/2139) ([tvdeyen](https://github.com/tvdeyen))
- Fix URL for dragonfly configuration reference [#2128](https://github.com/AlchemyCMS/alchemy_cms/pull/2128) ([afdev82](https://github.com/afdev82))
- Link dialog UI fixes [#2112](https://github.com/AlchemyCMS/alchemy_cms/pull/2112) ([tvdeyen](https://github.com/tvdeyen))
- [js] Upgrade babel-jest to version 27.0.1 [#2110](https://github.com/AlchemyCMS/alchemy_cms/pull/2110) ([depfu](https://github.com/apps/depfu))
- Fix node select height [#2102](https://github.com/AlchemyCMS/alchemy_cms/pull/2102) ([tvdeyen](https://github.com/tvdeyen))
- [ruby - main] Upgrade execjs to version 2.8.1 [#2100](https://github.com/AlchemyCMS/alchemy_cms/pull/2100) ([depfu](https://github.com/apps/depfu))
- Fix Essence Picture View (#2083) [#2099](https://github.com/AlchemyCMS/alchemy_cms/pull/2099) ([afdev82](https://github.com/afdev82))
- Pass crop parameter in default EssencePicture#picture_url_options [#2098](https://github.com/AlchemyCMS/alchemy_cms/pull/2098) ([mamhoff](https://github.com/mamhoff))
- [main] Fix execjs to 2.7.0 for developers and CI [#2095](https://github.com/AlchemyCMS/alchemy_cms/pull/2095) ([mamhoff](https://github.com/mamhoff))
- Fix alchemy:generate:thumbnails task [#2092](https://github.com/AlchemyCMS/alchemy_cms/pull/2092) ([afdev82](https://github.com/afdev82))
- Use symbols in polymorphic routes for resources [#2087](https://github.com/AlchemyCMS/alchemy_cms/pull/2087) ([tvdeyen](https://github.com/tvdeyen))
- Fix the height of node select [#2081](https://github.com/AlchemyCMS/alchemy_cms/pull/2081) ([tvdeyen](https://github.com/tvdeyen))
- Preview url fixes [#2079](https://github.com/AlchemyCMS/alchemy_cms/pull/2079) ([tvdeyen](https://github.com/tvdeyen))
- Use count over select.count in UrlPath class [#2078](https://github.com/AlchemyCMS/alchemy_cms/pull/2078) ([tvdeyen](https://github.com/tvdeyen))
- Use the fast DuplicateElement service in Page.copy [#2077](https://github.com/AlchemyCMS/alchemy_cms/pull/2077) ([tvdeyen](https://github.com/tvdeyen))
- Fix page versioning issues [#2076](https://github.com/AlchemyCMS/alchemy_cms/pull/2076) ([tvdeyen](https://github.com/tvdeyen))
- Fix add nested element with multiple nestable elements [#2052](https://github.com/AlchemyCMS/alchemy_cms/pull/2052) ([tvdeyen](https://github.com/tvdeyen))
- Destroy public version if public checkbox is unset [#2050](https://github.com/AlchemyCMS/alchemy_cms/pull/2050) ([tvdeyen](https://github.com/tvdeyen))
- Fixes paste element and create element with autogenerated nested elements [#2046](https://github.com/AlchemyCMS/alchemy_cms/pull/2046) ([tvdeyen](https://github.com/tvdeyen))
- Fix page re-publishing for page with nested elements [#2043](https://github.com/AlchemyCMS/alchemy_cms/pull/2043) ([tvdeyen](https://github.com/tvdeyen))
- Update rubocop config and stick version [#2042](https://github.com/AlchemyCMS/alchemy_cms/pull/2042) ([tvdeyen](https://github.com/tvdeyen))
- Fix factory loading [#2041](https://github.com/AlchemyCMS/alchemy_cms/pull/2041) ([tvdeyen](https://github.com/tvdeyen))
- Fix element re-ordering [#2028](https://github.com/AlchemyCMS/alchemy_cms/pull/2028) ([tvdeyen](https://github.com/tvdeyen))
- Fix typo in element destroy confirm notice [#2026](https://github.com/AlchemyCMS/alchemy_cms/pull/2026) ([tvdeyen](https://github.com/tvdeyen))
- Fix constants reloading in page and element concerns [#2024](https://github.com/AlchemyCMS/alchemy_cms/pull/2024) ([tvdeyen](https://github.com/tvdeyen))
- Fix delete element confirm dialog [#2023](https://github.com/AlchemyCMS/alchemy_cms/pull/2023) ([tvdeyen](https://github.com/tvdeyen))
- Build for Ruby 3 [#1990](https://github.com/AlchemyCMS/alchemy_cms/pull/1990) ([tvdeyen](https://github.com/tvdeyen))

## 5.2.7 (2022-03-01)

- Fix copying page with descendants to a different language ([dbwinger](https://github.com/dbwinger))
- Handle copying/pasting global pages ([dbwinger](https://github.com/dbwinger))

## 5.2.6 (2022-02-28)

- Add crop_resize Dragonfly processor ([tvdeyen](https://github.com/tvdeyen))

## 5.2.5 (2021-11-24)

- Adjust tinymce skin assets urls again ([tvdeyen](https://github.com/tvdeyen))

## 5.2.4 (2021-11-17)

- Set stampable user_class_name without root identifier ([tvdeyen](https://github.com/tvdeyen))
- Use relative path for tinymce font-face ([tvdeyen](https://github.com/tvdeyen))

## 5.2.3 (2021-10-26)

- Make sure to install correct npm package ([tvdeyen](https://github.com/tvdeyen))

## 5.2.2 (2021-09-15)

- Return only pages from current site in api [#2169](https://github.com/AlchemyCMS/alchemy_cms/pull/2169) ([afdev82](https://github.com/afdev82))
- Improve cache key defaults for menus #2138 [#2160](https://github.com/AlchemyCMS/alchemy_cms/pull/2160) ([oneiros](https://github.com/oneiros))
- generate picture thumbnails only for pictures with convertible format [#2130](https://github.com/AlchemyCMS/alchemy_cms/pull/2130) ([afdev82](https://github.com/afdev82))
- Backport #2114 to v5.2 [#2116](https://github.com/AlchemyCMS/alchemy_cms/pull/2116) ([afdev82](https://github.com/afdev82))
- Add webpacker tasks to Alchemy upgrader [#2115](https://github.com/AlchemyCMS/alchemy_cms/pull/2115) ([dbwinger](https://github.com/dbwinger))

## 5.2.1 (2021-05-13)

- Fix alchemy:generate:thumbnails task [#2092](https://github.com/AlchemyCMS/alchemy_cms/pull/2092) ([afdev82](https://github.com/afdev82))
- Do not attempt to generate thumbs for svg files. [#2090](https://github.com/AlchemyCMS/alchemy_cms/pull/2090) ([oneiros](https://github.com/oneiros))

## 5.2.0 (2021-05-06)

- Backport #2049 to 5.2 [#2086](https://github.com/AlchemyCMS/alchemy_cms/pull/2086) ([rickythefox](https://github.com/rickythefox))
- hotfix and deprecate page_active? helper [#2073](https://github.com/AlchemyCMS/alchemy_cms/pull/2073) ([robinboening](https://github.com/robinboening))

## 5.2.0.rc1 (2021-02-17)

### Changes

- Change Factory loading mechanism to FactoryBots supported mechanism [#2030](https://github.com/AlchemyCMS/alchemy_cms/pull/2030) ([mamhoff](https://github.com/mamhoff))

## 5.2.0.b1 (2021-02-11)

### Features

- Allow Element and Content deprecation notices [#1988](https://github.com/AlchemyCMS/alchemy_cms/pull/1988) ([tvdeyen](https://github.com/tvdeyen))
- Add element definition api (based on PageLayout definitions) [#1986](https://github.com/AlchemyCMS/alchemy_cms/pull/1986) ([stockime](https://github.com/stockime))

### Changes

- Fix jpeg quality option for jpeg files [#2016](https://github.com/AlchemyCMS/alchemy_cms/pull/2016) ([kulturbande](https://github.com/kulturbande))
- Pin Ransack to below 2.4.2 [#2012](https://github.com/AlchemyCMS/alchemy_cms/pull/2012) ([tvdeyen](https://github.com/tvdeyen))
- Fix setting current_user in integration helper [#2006](https://github.com/AlchemyCMS/alchemy_cms/pull/2006) ([tvdeyen](https://github.com/tvdeyen))
- Update mime type icons and translations [#2002](https://github.com/AlchemyCMS/alchemy_cms/pull/2002) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate page layout change [#1993](https://github.com/AlchemyCMS/alchemy_cms/pull/1993) ([tvdeyen](https://github.com/tvdeyen))
- Fix Ruby 2.7 deprecations [#1989](https://github.com/AlchemyCMS/alchemy_cms/pull/1989) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate trash [#1985](https://github.com/AlchemyCMS/alchemy_cms/pull/1985) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate elements fallbacks [#1982](https://github.com/AlchemyCMS/alchemy_cms/pull/1982) ([tvdeyen](https://github.com/tvdeyen))

### Misc

- Use Ubuntu 18.04 on GH actions [#2018](https://github.com/AlchemyCMS/alchemy_cms/pull/2018) ([tvdeyen](https://github.com/tvdeyen))
- [ruby - main] Upgrade rubocop to version 1.9.0 [#2011](https://github.com/AlchemyCMS/alchemy_cms/pull/2011) ([depfu](https://github.com/apps/depfu))
- [ruby - main] Upgrade rubocop to version 1.8.1 [#1999](https://github.com/AlchemyCMS/alchemy_cms/pull/1999) ([depfu](https://github.com/apps/depfu))
- Update brakeman ignores [#1992](https://github.com/AlchemyCMS/alchemy_cms/pull/1992) ([tvdeyen](https://github.com/tvdeyen))
- [ruby - main] Upgrade rubocop to version 1.6.1 [#1978](https://github.com/AlchemyCMS/alchemy_cms/pull/1978) ([depfu](https://github.com/apps/depfu))
- [ruby - main] Upgrade simplecov to version 0.20.0 [#1971](https://github.com/AlchemyCMS/alchemy_cms/pull/1971) ([depfu](https://github.com/apps/depfu))

## 5.1.2 (2021-01-26)

- Allow to safe hidden elements [#2007](https://github.com/AlchemyCMS/alchemy_cms/pull/2007) ([tvdeyen](https://github.com/tvdeyen))


## 5.1.1 (2021-01-12)

- Fix copy element feature [#1996](https://github.com/AlchemyCMS/alchemy_cms/pull/1996) ([tvdeyen](https://github.com/tvdeyen))

## 5.1.0 (2020-12-18)

### Features

- Allow pound sign in legacy url [#1980](https://github.com/AlchemyCMS/alchemy_cms/pull/1980) ([robinboening](https://github.com/robinboening))
- Adjust element editor UI [#1979](https://github.com/AlchemyCMS/alchemy_cms/pull/1979) ([tvdeyen](https://github.com/tvdeyen))
- Always show the full page name in active page tab [#1972](https://github.com/AlchemyCMS/alchemy_cms/pull/1972) ([tvdeyen](https://github.com/tvdeyen))
- Allow multiple preview sources [#1959](https://github.com/AlchemyCMS/alchemy_cms/pull/1959) ([tvdeyen](https://github.com/tvdeyen))
- Add Publish Targets [#1957](https://github.com/AlchemyCMS/alchemy_cms/pull/1957) ([tvdeyen](https://github.com/tvdeyen))
- Persist rendered picture variants [#1882](https://github.com/AlchemyCMS/alchemy_cms/pull/1882) ([tvdeyen](https://github.com/tvdeyen))
- Store current pictures size in session [#1927](https://github.com/AlchemyCMS/alchemy_cms/pull/1927) ([tvdeyen](https://github.com/tvdeyen))
- Add support for custom mount points in Page::UrlPath [#1921](https://github.com/AlchemyCMS/alchemy_cms/pull/1921) ([tvdeyen](https://github.com/tvdeyen))
- Allow to set a custom Page::UrlPath class [#1919](https://github.com/AlchemyCMS/alchemy_cms/pull/1919) ([tvdeyen](https://github.com/tvdeyen))
- Introduce a pages list view [#1906](https://github.com/AlchemyCMS/alchemy_cms/pull/1906) ([tvdeyen](https://github.com/tvdeyen))

### Changes

- Fix height of search input field [#1973](https://github.com/AlchemyCMS/alchemy_cms/pull/1973) ([tvdeyen](https://github.com/tvdeyen))
- Load select2 from assets folder [#1961](https://github.com/AlchemyCMS/alchemy_cms/pull/1961) ([tvdeyen](https://github.com/tvdeyen))
- Do not abort if user class cannot be found [#1950](https://github.com/AlchemyCMS/alchemy_cms/pull/1950) ([tvdeyen](https://github.com/tvdeyen))
- Deprivatize useful picture view methods [#1936](https://github.com/AlchemyCMS/alchemy_cms/pull/1936) ([mickenorlen](https://github.com/mickenorlen))
- Unset render_size on layout default selection [#1935](https://github.com/AlchemyCMS/alchemy_cms/pull/1935) ([mickenorlen](https://github.com/mickenorlen))
- Dont show sizes selection if using srcset [#1934](https://github.com/AlchemyCMS/alchemy_cms/pull/1934) ([mickenorlen](https://github.com/mickenorlen))
- Change all Boolean columns to never be null [#1933](https://github.com/AlchemyCMS/alchemy_cms/pull/1933) ([mamhoff](https://github.com/mamhoff))
- Autoselect first if only one layout available [#1932](https://github.com/AlchemyCMS/alchemy_cms/pull/1932) ([mickenorlen](https://github.com/mickenorlen))
- Remove page from search form query [#1928](https://github.com/AlchemyCMS/alchemy_cms/pull/1928) ([tvdeyen](https://github.com/tvdeyen))
- Allow coffee-rails 5 [#1926](https://github.com/AlchemyCMS/alchemy_cms/pull/1926) ([sechix](https://github.com/sechix))
- Update documentation [#1917](https://github.com/AlchemyCMS/alchemy_cms/pull/1917) ([dhughesbc](https://github.com/dhughesbc))
- Remove deprecated Attachment#urlname [#1911](https://github.com/AlchemyCMS/alchemy_cms/pull/1911) ([tvdeyen](https://github.com/tvdeyen))
- Remove redirect_to_public_child flag and feature [#1910](https://github.com/AlchemyCMS/alchemy_cms/pull/1910) ([tvdeyen](https://github.com/tvdeyen))
- Remove toolbar helper [#1909](https://github.com/AlchemyCMS/alchemy_cms/pull/1909) ([tvdeyen](https://github.com/tvdeyen))
- Two minor CSS fixes [#1908](https://github.com/AlchemyCMS/alchemy_cms/pull/1908) ([tvdeyen](https://github.com/tvdeyen))
- Do not convert JPG images into JPEG [#1905](https://github.com/AlchemyCMS/alchemy_cms/pull/1905) ([tvdeyen](https://github.com/tvdeyen))
- Full text search respects filters [#1901](https://github.com/AlchemyCMS/alchemy_cms/pull/1901) ([tvdeyen](https://github.com/tvdeyen))
- Do not add id attributes to hidden fields in search and filters [#1899](https://github.com/AlchemyCMS/alchemy_cms/pull/1899) ([tvdeyen](https://github.com/tvdeyen))
- Do not freeze common_search_filter_includes [#1898](https://github.com/AlchemyCMS/alchemy_cms/pull/1898) ([tvdeyen](https://github.com/tvdeyen))
- Refactor sidebar CSS [#1897](https://github.com/AlchemyCMS/alchemy_cms/pull/1897) ([tvdeyen](https://github.com/tvdeyen))
- Fix tag-list height [#1896](https://github.com/AlchemyCMS/alchemy_cms/pull/1896) ([tvdeyen](https://github.com/tvdeyen))
- Fix vertical position of site name in page tab [#1895](https://github.com/AlchemyCMS/alchemy_cms/pull/1895) ([tvdeyen](https://github.com/tvdeyen))
- Support nested controllers in modules [#1894](https://github.com/AlchemyCMS/alchemy_cms/pull/1894) ([tvdeyen](https://github.com/tvdeyen))
- Always make pages taggable [#1893](https://github.com/AlchemyCMS/alchemy_cms/pull/1893) ([tvdeyen](https://github.com/tvdeyen))
- Fix editing sites [#1891](https://github.com/AlchemyCMS/alchemy_cms/pull/1891) ([mamhoff](https://github.com/mamhoff))
- Fix missing help_text_text translations [#1888](https://github.com/AlchemyCMS/alchemy_cms/pull/1888) ([gr8bit](https://github.com/gr8bit))

### Misc

- Move away from Travis CI [#1981](https://github.com/AlchemyCMS/alchemy_cms/pull/1981) ([tvdeyen](https://github.com/tvdeyen))
- Remove poltergeist and phantomjs leftovers [#1970](https://github.com/AlchemyCMS/alchemy_cms/pull/1970) ([tvdeyen](https://github.com/tvdeyen))
- [ruby - main] Upgrade rubocop to version 1.1.0 [#1958](https://github.com/AlchemyCMS/alchemy_cms/pull/1958) ([depfu](https://github.com/apps/depfu))
- Remove greetings action [#1956](https://github.com/AlchemyCMS/alchemy_cms/pull/1956) ([tvdeyen](https://github.com/tvdeyen))
- [ruby] Upgrade rubocop to version 1.0.0 [#1952](https://github.com/AlchemyCMS/alchemy_cms/pull/1952) ([depfu](https://github.com/apps/depfu))
- [ruby] Upgrade rubocop to version 0.93.1 [#1948](https://github.com/AlchemyCMS/alchemy_cms/pull/1948) ([depfu](https://github.com/apps/depfu))
- [ruby] Upgrade puma to version 5.0.2 [#1944](https://github.com/AlchemyCMS/alchemy_cms/pull/1944) ([depfu](https://github.com/apps/depfu))
- [ruby] Upgrade rubocop to version 0.92.0 [#1942](https://github.com/AlchemyCMS/alchemy_cms/pull/1942) ([depfu](https://github.com/apps/depfu))
- Use Node 12 on CI runs [#1925](https://github.com/AlchemyCMS/alchemy_cms/pull/1925) ([tvdeyen](https://github.com/tvdeyen))
- [ruby] Upgrade rubocop to version 0.89.0 [#1920](https://github.com/AlchemyCMS/alchemy_cms/pull/1920) ([depfu](https://github.com/apps/depfu))
- Move back to Travis CI [#1907](https://github.com/AlchemyCMS/alchemy_cms/pull/1907) ([tvdeyen](https://github.com/tvdeyen))
- [ruby] Upgrade rubocop to version 0.88.0 [#1892](https://github.com/AlchemyCMS/alchemy_cms/pull/1892) ([depfu](https://github.com/apps/depfu))
- [ruby] Upgrade rubocop to version 0.87.1 [#1889](https://github.com/AlchemyCMS/alchemy_cms/pull/1889) ([depfu](https://github.com/apps/depfu))

## 5.0.3 (2021-01-12)

- Fix copy element feature [#1996](https://github.com/AlchemyCMS/alchemy_cms/pull/1996) ([tvdeyen](https://github.com/tvdeyen))

## 5.0.2 (2020-12-18)

- Fix page sorting [#1984](https://github.com/AlchemyCMS/alchemy_cms/pull/1984) ([tvdeyen](https://github.com/tvdeyen))

## 5.0.1 (2020-09-29)

- [a11y] Better image alt text support [#1940](https://github.com/AlchemyCMS/alchemy_cms/pull/1940) ([tvdeyen](https://github.com/tvdeyen))

## 5.0.0 (2020-07-17)

- Do not convert JPEG images into JPG [#1904](https://github.com/AlchemyCMS/alchemy_cms/pull/1904) ([tvdeyen](https://github.com/tvdeyen))
- Do not enable image cropper if file is missing [#1903](https://github.com/AlchemyCMS/alchemy_cms/pull/1903) ([tvdeyen](https://github.com/tvdeyen))
- Always show original image as zoomed image [#1902](https://github.com/AlchemyCMS/alchemy_cms/pull/1902) ([tvdeyen](https://github.com/tvdeyen))
- Rename Attachment#urlname into slug [#1848](https://github.com/AlchemyCMS/alchemy_cms/pull/1848) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate toolbar helper [#1900](https://github.com/AlchemyCMS/alchemy_cms/pull/1900) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate redirect_to_public_child ([tvdeyen](https://github.com/tvdeyen))
- Add --auto-accept option to installer ([tvdeyen](https://github.com/tvdeyen))
- Move all installer code into install generator ([tvdeyen](https://github.com/tvdeyen))
- Language Factory: Create default language in host app's locale [#1884](https://github.com/AlchemyCMS/alchemy_cms/pull/1884) ([mamhoff](https://github.com/mamhoff))
- Respect filter and tagging params in picture archive size buttons [#1880](https://github.com/AlchemyCMS/alchemy_cms/pull/1880) ([tvdeyen](https://github.com/tvdeyen))
- Extract picture thumbnail sizes in a constant [#1879](https://github.com/AlchemyCMS/alchemy_cms/pull/1879) ([tvdeyen](https://github.com/tvdeyen))
- Configurable Image Preprocessor [#1878](https://github.com/AlchemyCMS/alchemy_cms/pull/1878) ([tvdeyen](https://github.com/tvdeyen))
- Configure edit page preview per site [#1877](https://github.com/AlchemyCMS/alchemy_cms/pull/1877) ([tvdeyen](https://github.com/tvdeyen))
- Fix Page tree sorting after root page removal [#1876](https://github.com/AlchemyCMS/alchemy_cms/pull/1876) ([tvdeyen](https://github.com/tvdeyen))
- 5.0 Upgrader fixes [#1874](https://github.com/AlchemyCMS/alchemy_cms/pull/1874) ([tvdeyen](https://github.com/tvdeyen))
- Remove url_nesting config [#1872](https://github.com/AlchemyCMS/alchemy_cms/pull/1872) ([tvdeyen](https://github.com/tvdeyen))
- [ruby] Upgrade sassc to version 2.4.0 [#1871](https://github.com/AlchemyCMS/alchemy_cms/pull/1871) ([depfu](https://github.com/apps/depfu))
- fix GitHub Actions spelling [#1869](https://github.com/AlchemyCMS/alchemy_cms/pull/1869) ([alexanderadam](https://github.com/alexanderadam))
- Remove Page#visible [#1868](https://github.com/AlchemyCMS/alchemy_cms/pull/1868) ([tvdeyen](https://github.com/tvdeyen))
- 4.6 backports for master [#1867](https://github.com/AlchemyCMS/alchemy_cms/pull/1867) ([tvdeyen](https://github.com/tvdeyen))
- Use apt update instead of apt-get in GH action [#1866](https://github.com/AlchemyCMS/alchemy_cms/pull/1866) ([tvdeyen](https://github.com/tvdeyen))
- [ruby] Upgrade rubocop to version 0.85.0 [#1863](https://github.com/AlchemyCMS/alchemy_cms/pull/1863) ([depfu](https://github.com/apps/depfu))
- Remove active_record_5_1? method [#1854](https://github.com/AlchemyCMS/alchemy_cms/pull/1854) ([tvdeyen](https://github.com/tvdeyen))
- Use Alchemy npm package instead of hacking webpacker [#1853](https://github.com/AlchemyCMS/alchemy_cms/pull/1853) ([tvdeyen](https://github.com/tvdeyen))
- Fix node select ES5 syntax [#1851](https://github.com/AlchemyCMS/alchemy_cms/pull/1851) ([tvdeyen](https://github.com/tvdeyen))
- Run yarn:install after installing webpacker in install generator [#1850](https://github.com/AlchemyCMS/alchemy_cms/pull/1850) ([mamhoff](https://github.com/mamhoff))
- Remove male sign after emoji [#1849](https://github.com/AlchemyCMS/alchemy_cms/pull/1849) ([mamhoff](https://github.com/mamhoff))
- Do not use ES6 Syntax in Node Selector [#1846](https://github.com/AlchemyCMS/alchemy_cms/pull/1846) ([mamhoff](https://github.com/mamhoff))
- [ruby] Upgrade rubocop to version 0.84.0 [#1845](https://github.com/AlchemyCMS/alchemy_cms/pull/1845) ([depfu](https://github.com/apps/depfu))
- Always create nested urls [#1844](https://github.com/AlchemyCMS/alchemy_cms/pull/1844) ([tvdeyen](https://github.com/tvdeyen))
- Fix: Add indifferent access to default options in encoded_image [#1840](https://github.com/AlchemyCMS/alchemy_cms/pull/1840) ([mickenorlen](https://github.com/mickenorlen))
- Set proper nested set scope on page [#1837](https://github.com/AlchemyCMS/alchemy_cms/pull/1837) ([tvdeyen](https://github.com/tvdeyen))
- Install Webpacker in install generator [#1835](https://github.com/AlchemyCMS/alchemy_cms/pull/1835) ([mamhoff](https://github.com/mamhoff))
- Fix deleting an EssenceNode from a content [#1834](https://github.com/AlchemyCMS/alchemy_cms/pull/1834) ([mamhoff](https://github.com/mamhoff))
- Use Rails standards for deleting pages from EssencePage [#1833](https://github.com/AlchemyCMS/alchemy_cms/pull/1833) ([mamhoff](https://github.com/mamhoff))
- Scope has one site [#1832](https://github.com/AlchemyCMS/alchemy_cms/pull/1832) ([mamhoff](https://github.com/mamhoff))
- Render nodes [#1831](https://github.com/AlchemyCMS/alchemy_cms/pull/1831) ([mamhoff](https://github.com/mamhoff))
- Add errors when node cant be deleted [#1828](https://github.com/AlchemyCMS/alchemy_cms/pull/1828) ([mamhoff](https://github.com/mamhoff))
- Add error flash to resource controller [#1827](https://github.com/AlchemyCMS/alchemy_cms/pull/1827) ([mamhoff](https://github.com/mamhoff))
- Fix Association between Nodes and EssenceNodes [#1826](https://github.com/AlchemyCMS/alchemy_cms/pull/1826) ([mamhoff](https://github.com/mamhoff))
- Translated root menus [#1825](https://github.com/AlchemyCMS/alchemy_cms/pull/1825) ([mamhoff](https://github.com/mamhoff))
- Use rails root in install generator [#1822](https://github.com/AlchemyCMS/alchemy_cms/pull/1822) ([tvdeyen](https://github.com/tvdeyen))
- Add a quick Node select [#1821](https://github.com/AlchemyCMS/alchemy_cms/pull/1821) ([mamhoff](https://github.com/mamhoff))
- Add has_one association for root page [#1820](https://github.com/AlchemyCMS/alchemy_cms/pull/1820) ([mamhoff](https://github.com/mamhoff))
- [js] Upgrade babel-jest to version 26.0.1 [#1819](https://github.com/AlchemyCMS/alchemy_cms/pull/1819) ([depfu](https://github.com/apps/depfu))
- Make page language mandatory [#1818](https://github.com/AlchemyCMS/alchemy_cms/pull/1818) ([tvdeyen](https://github.com/tvdeyen))
- Remove root page [#1817](https://github.com/AlchemyCMS/alchemy_cms/pull/1817) ([tvdeyen](https://github.com/tvdeyen))
- Fix page unlock page icon replacement [#1816](https://github.com/AlchemyCMS/alchemy_cms/pull/1816) ([tvdeyen](https://github.com/tvdeyen))
- Invoke rake task in upgrader instead of system call [#1815](https://github.com/AlchemyCMS/alchemy_cms/pull/1815) ([tvdeyen](https://github.com/tvdeyen))
- Remove old 4.4 upgrader class [#1814](https://github.com/AlchemyCMS/alchemy_cms/pull/1814) ([tvdeyen](https://github.com/tvdeyen))
- Remove Page.ancestors_for [#1813](https://github.com/AlchemyCMS/alchemy_cms/pull/1813) ([tvdeyen](https://github.com/tvdeyen))
- Remove layout root pages [#1812](https://github.com/AlchemyCMS/alchemy_cms/pull/1812) ([tvdeyen](https://github.com/tvdeyen))
- Use timestamps in migration [#1811](https://github.com/AlchemyCMS/alchemy_cms/pull/1811) ([tvdeyen](https://github.com/tvdeyen))
- Remove legacy element serializer [#1810](https://github.com/AlchemyCMS/alchemy_cms/pull/1810) ([tvdeyen](https://github.com/tvdeyen))
- Remove timestamps from essences and contents [#1809](https://github.com/AlchemyCMS/alchemy_cms/pull/1809) ([tvdeyen](https://github.com/tvdeyen))
- Remove stamper from contents [#1808](https://github.com/AlchemyCMS/alchemy_cms/pull/1808) ([tvdeyen](https://github.com/tvdeyen))
- Remove Site ID from nodes [#1807](https://github.com/AlchemyCMS/alchemy_cms/pull/1807) ([mamhoff](https://github.com/mamhoff))
- Add Alchemy::Language.has_many :nodes [#1806](https://github.com/AlchemyCMS/alchemy_cms/pull/1806) ([mamhoff](https://github.com/mamhoff))
- Drop Rails 5.0 and 5.1 support [#1805](https://github.com/AlchemyCMS/alchemy_cms/pull/1805) ([tvdeyen](https://github.com/tvdeyen))
- Remove enforce_ssl [#1804](https://github.com/AlchemyCMS/alchemy_cms/pull/1804) ([tvdeyen](https://github.com/tvdeyen))
- Make the preview url configurable [#1803](https://github.com/AlchemyCMS/alchemy_cms/pull/1803) ([tvdeyen](https://github.com/tvdeyen))
- Remove stamper from essences [#1802](https://github.com/AlchemyCMS/alchemy_cms/pull/1802) ([tvdeyen](https://github.com/tvdeyen))
- Use Rufo to format all files in a consistent way [#1799](https://github.com/AlchemyCMS/alchemy_cms/pull/1799) ([tvdeyen](https://github.com/tvdeyen))
- Remove acts_as_list from Content [#1798](https://github.com/AlchemyCMS/alchemy_cms/pull/1798) ([tvdeyen](https://github.com/tvdeyen))
- Add EssenceNode [#1792](https://github.com/AlchemyCMS/alchemy_cms/pull/1792) ([mamhoff](https://github.com/mamhoff))
- Use 2.5.7 of code climate coverage reporter GH action [#1790](https://github.com/AlchemyCMS/alchemy_cms/pull/1790) ([tvdeyen](https://github.com/tvdeyen))
- [ruby] Upgrade sassc to version 2.3.0 [#1787](https://github.com/AlchemyCMS/alchemy_cms/pull/1787) ([depfu](https://github.com/apps/depfu))
- [ruby] Upgrade rubocop to version 0.82.0 [#1785](https://github.com/AlchemyCMS/alchemy_cms/pull/1785) ([depfu](https://github.com/apps/depfu))
- Fix regular icons [#1784](https://github.com/AlchemyCMS/alchemy_cms/pull/1784) ([tvdeyen](https://github.com/tvdeyen))
- Convert NodeTree into ES6 [#1782](https://github.com/AlchemyCMS/alchemy_cms/pull/1782) ([tvdeyen](https://github.com/tvdeyen))
- Add Webpacker [#1775](https://github.com/AlchemyCMS/alchemy_cms/pull/1775) ([tvdeyen](https://github.com/tvdeyen))
- Multi language menus [#1774](https://github.com/AlchemyCMS/alchemy_cms/pull/1774) ([rmparr](https://github.com/rmparr))
- On Boarding Flow [#1770](https://github.com/AlchemyCMS/alchemy_cms/pull/1770) ([tvdeyen](https://github.com/tvdeyen))
- Fix bug in language from session w/o site [#1769](https://github.com/AlchemyCMS/alchemy_cms/pull/1769) ([tvdeyen](https://github.com/tvdeyen))
- Fix fontawesome in production [#1765](https://github.com/AlchemyCMS/alchemy_cms/pull/1765) ([mickenorlen](https://github.com/mickenorlen))
- Remove implicit Site and Language creation [#1763](https://github.com/AlchemyCMS/alchemy_cms/pull/1763) ([mamhoff](https://github.com/mamhoff))
- Add content editor data attributes based on name/id and css_classes presenter method [#1761](https://github.com/AlchemyCMS/alchemy_cms/pull/1761) ([mickenorlen](https://github.com/mickenorlen))
- Add alchemy.test to development domains [#1760](https://github.com/AlchemyCMS/alchemy_cms/pull/1760) ([tvdeyen](https://github.com/tvdeyen))
- Update Fontawesome [#1759](https://github.com/AlchemyCMS/alchemy_cms/pull/1759) ([tvdeyen](https://github.com/tvdeyen))
- Fix test coverage reporting [#1757](https://github.com/AlchemyCMS/alchemy_cms/pull/1757) ([tvdeyen](https://github.com/tvdeyen))
- Remove references to nonexistent "scaffold" generator [#1755](https://github.com/AlchemyCMS/alchemy_cms/pull/1755) ([mamhoff](https://github.com/mamhoff))
- Remove Tasks::Helper module [#1754](https://github.com/AlchemyCMS/alchemy_cms/pull/1754) ([mamhoff](https://github.com/mamhoff))
- Update rubocop [#1753](https://github.com/AlchemyCMS/alchemy_cms/pull/1753) ([tvdeyen](https://github.com/tvdeyen))
- chores: use same _old_ Rubo:cop: version as Hound [#1752](https://github.com/AlchemyCMS/alchemy_cms/pull/1752) ([alexanderadam](https://github.com/alexanderadam))
- Fix date comparison in resource feature spec [#1750](https://github.com/AlchemyCMS/alchemy_cms/pull/1750) ([tvdeyen](https://github.com/tvdeyen))
- Fail spec prepare task if sub command fails [#1749](https://github.com/AlchemyCMS/alchemy_cms/pull/1749) ([tvdeyen](https://github.com/tvdeyen))
- Add MySQL service as service [#1748](https://github.com/AlchemyCMS/alchemy_cms/pull/1748) ([mamhoff](https://github.com/mamhoff))
- Allow importing to a different port [#1747](https://github.com/AlchemyCMS/alchemy_cms/pull/1747) ([mamhoff](https://github.com/mamhoff))
- Sortable resources tables [#1744](https://github.com/AlchemyCMS/alchemy_cms/pull/1744) ([tvdeyen](https://github.com/tvdeyen))
- Fix update check spec [#1743](https://github.com/AlchemyCMS/alchemy_cms/pull/1743) ([tvdeyen](https://github.com/tvdeyen))
- Compress migrations [#1657](https://github.com/AlchemyCMS/alchemy_cms/pull/1657) ([tvdeyen](https://github.com/tvdeyen))
- Install Gutentag migrations while installing Alchemy [#1688](https://github.com/AlchemyCMS/alchemy_cms/pull/1688) ([tvdeyen](https://github.com/tvdeyen))
- Remove old upgrade tasks [#1687](https://github.com/AlchemyCMS/alchemy_cms/pull/1687) ([tvdeyen](https://github.com/tvdeyen))
- Remove deprecated features [#1686](https://github.com/AlchemyCMS/alchemy_cms/pull/1686) ([tvdeyen](https://github.com/tvdeyen))
- Remove deprecations [#1656](https://github.com/AlchemyCMS/alchemy_cms/pull/1656) ([tvdeyen](https://github.com/tvdeyen))
- Add element editor decorator [#1653](https://github.com/AlchemyCMS/alchemy_cms/pull/1653) ([tvdeyen](https://github.com/tvdeyen))
- Remove deprecated render_essence_* helpers [#1652](https://github.com/AlchemyCMS/alchemy_cms/pull/1652) ([tvdeyen](https://github.com/tvdeyen))
- Remove deprecated render element editor helpers [#1651](https://github.com/AlchemyCMS/alchemy_cms/pull/1651) ([tvdeyen](https://github.com/tvdeyen))
- Add ContentEditor decorator [#1645](https://github.com/AlchemyCMS/alchemy_cms/pull/1645) ([tvdeyen](https://github.com/tvdeyen))
- Remove local options from essence editors [#1638](https://github.com/AlchemyCMS/alchemy_cms/pull/1638) ([tvdeyen](https://github.com/tvdeyen))

## 4.6.1 (2020-06-04)

- Fix 4.6 upgrader

## 4.6.0 (2020-06-04)

- Use apt update instead of apt-get in GH action [#1865](https://github.com/AlchemyCMS/alchemy_cms/pull/1865) ([tvdeyen](https://github.com/tvdeyen))
- Use depth for page tree serializer root_or_leaf [#1864](https://github.com/AlchemyCMS/alchemy_cms/pull/1864) ([tvdeyen](https://github.com/tvdeyen))
- Fix sitemap wrapper height [#1861](https://github.com/AlchemyCMS/alchemy_cms/pull/1861) ([tvdeyen](https://github.com/tvdeyen))
- Do not return the root page with API responses. [#1860](https://github.com/AlchemyCMS/alchemy_cms/pull/1860) ([tvdeyen](https://github.com/tvdeyen))
- Introduce page.url_path and use it for alchemyPageSelect [#1859](https://github.com/AlchemyCMS/alchemy_cms/pull/1859) ([tvdeyen](https://github.com/tvdeyen))
- Update Urlname translation [#1857](https://github.com/AlchemyCMS/alchemy_cms/pull/1857) ([tvdeyen](https://github.com/tvdeyen))
- Show url name in Page tree [#1856](https://github.com/AlchemyCMS/alchemy_cms/pull/1856) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate Page#visible attribute [#1855](https://github.com/AlchemyCMS/alchemy_cms/pull/1855) ([tvdeyen](https://github.com/tvdeyen))
- 4.6: Re-add `auto_logout_time` configuration option [#1852](https://github.com/AlchemyCMS/alchemy_cms/pull/1852) ([mamhoff](https://github.com/mamhoff))
- Backport ContentEditor to 4.6, deprecate removed methods on `Alchemy::Content` [#1847](https://github.com/AlchemyCMS/alchemy_cms/pull/1847) ([mamhoff](https://github.com/mamhoff))
- Deprecate auto_logout_time (4.6) [#1843](https://github.com/AlchemyCMS/alchemy_cms/pull/1843) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate require_ssl (4.6) [#1842](https://github.com/AlchemyCMS/alchemy_cms/pull/1842) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate url_nesting configuration (4.6) [#1841](https://github.com/AlchemyCMS/alchemy_cms/pull/1841) ([tvdeyen](https://github.com/tvdeyen))
- Allow page visible toggle (4.6) [#1838](https://github.com/AlchemyCMS/alchemy_cms/pull/1838) ([tvdeyen](https://github.com/tvdeyen))

## 4.5.0 (2020-03-30)

- Sortable menus [#1758](https://github.com/AlchemyCMS/alchemy_cms/pull/1758) ([mamhoff](https://github.com/mamhoff))
- Programmatic menus [#1756](https://github.com/AlchemyCMS/alchemy_cms/pull/1756) ([mamhoff](https://github.com/mamhoff))
- Fix syntax in non-erb Menu templates [#1751]((https://github.com/AlchemyCMS/alchemy_cms/pull/1751)) ([Alexander ADAM](https://github.com/alexanderadam))
- Fix `render_menu` for custom controllers [#1746]((https://github.com/AlchemyCMS/alchemy_cms/pull/1746)) ([Alexander ADAM](https://github.com/alexanderadam))

## 4.4.4 (2020-02-28)

- Fix new menu form [#1740](https://github.com/AlchemyCMS/alchemy_cms/pull/1740) ([tvdeyen](https://github.com/tvdeyen))

## 4.4.3 (2020-02-26)

- Scope nodes to sites [#1738](https://github.com/AlchemyCMS/alchemy_cms/pull/1738) ([tvdeyen](https://github.com/tvdeyen))

## 4.4.2 (2020-02-25)

- Do not use deprecated methods [#1737](https://github.com/AlchemyCMS/alchemy_cms/pull/1737) ([tvdeyen](https://github.com/tvdeyen))
- Order contents by their position in its element [#1733](https://github.com/AlchemyCMS/alchemy_cms/pull/1733) ([tvdeyen](https://github.com/tvdeyen))
- Eager load relations in elements trash [#1732](https://github.com/AlchemyCMS/alchemy_cms/pull/1732) ([tvdeyen](https://github.com/tvdeyen))
- Run CI builds with Sprockets 3.7.2 [#1731](https://github.com/AlchemyCMS/alchemy_cms/pull/1731) ([tvdeyen](https://github.com/tvdeyen))
- Re-organize development dependencies [#1730](https://github.com/AlchemyCMS/alchemy_cms/pull/1730) ([tvdeyen](https://github.com/tvdeyen))
- Update pr template [#1729](https://github.com/AlchemyCMS/alchemy_cms/pull/1729) ([tvdeyen](https://github.com/tvdeyen))
- Generate views without _view in the filename [#1728](https://github.com/AlchemyCMS/alchemy_cms/pull/1728) ([tvdeyen](https://github.com/tvdeyen))
- Fix CI Builds [#1727](https://github.com/AlchemyCMS/alchemy_cms/pull/1727) ([tvdeyen](https://github.com/tvdeyen))
- Fix page tagging condition: should_attach_to_menu?  [#1725](https://github.com/AlchemyCMS/alchemy_cms/pull/1725) ([mickenorlen](https://github.com/mickenorlen))
- Fix Alchemy.user_class_name constant conflict [#1724](https://github.com/AlchemyCMS/alchemy_cms/pull/1724) ([mickenorlen](https://github.com/mickenorlen))

## 4.4.1 (2020-01-08)

- Fix updating page preview after element create/save [#1710](https://github.com/AlchemyCMS/alchemy_cms/pull/1710) ([tvdeyen](https://github.com/tvdeyen))
- Element editor layout changes [#1709](https://github.com/AlchemyCMS/alchemy_cms/pull/1709) ([tvdeyen](https://github.com/tvdeyen))
- Add Alchemy.user_class_primary_key setting [#1708](https://github.com/AlchemyCMS/alchemy_cms/pull/1708) ([tvdeyen](https://github.com/tvdeyen))
- Add Element views upgrade tasks [#1707](https://github.com/AlchemyCMS/alchemy_cms/pull/1707) ([tvdeyen](https://github.com/tvdeyen))
- Use postMessage to send messages between preview and element windows [#1704](https://github.com/AlchemyCMS/alchemy_cms/pull/1704) ([tvdeyen](https://github.com/tvdeyen))

## 4.4.0 (2020-01-06)

- Use contents settings for size in EssencePicture#picture_url [#1703](https://github.com/AlchemyCMS/alchemy_cms/pull/1703) ([tvdeyen](https://github.com/tvdeyen))
- Remove title tag from preview elements [#1701](https://github.com/AlchemyCMS/alchemy_cms/pull/1701) ([tvdeyen](https://github.com/tvdeyen))
- Remove custom JS logging [#1700](https://github.com/AlchemyCMS/alchemy_cms/pull/1700) ([tvdeyen](https://github.com/tvdeyen))
- Remove demo locale files [#1699](https://github.com/AlchemyCMS/alchemy_cms/pull/1699) ([tvdeyen](https://github.com/tvdeyen))
- Use alchemyPageSelect for Node page select [#1698](https://github.com/AlchemyCMS/alchemy_cms/pull/1698) ([tvdeyen](https://github.com/tvdeyen))
- Cache menu partials [#1697](https://github.com/AlchemyCMS/alchemy_cms/pull/1697) ([tvdeyen](https://github.com/tvdeyen))
- Update page tree to menu nodes Rake task [#1696](https://github.com/AlchemyCMS/alchemy_cms/pull/1696) ([tvdeyen](https://github.com/tvdeyen))
- Validate nodes name if page is absent [#1695](https://github.com/AlchemyCMS/alchemy_cms/pull/1695) ([tvdeyen](https://github.com/tvdeyen))
- Update the application layout installer template [#1691](https://github.com/AlchemyCMS/alchemy_cms/pull/1691) ([tvdeyen](https://github.com/tvdeyen))
- Update note about missing user class [#1690](https://github.com/AlchemyCMS/alchemy_cms/pull/1690) ([tvdeyen](https://github.com/tvdeyen))
- Use a Sprockets 3/4 manifest file [#1689](https://github.com/AlchemyCMS/alchemy_cms/pull/1689) ([tvdeyen](https://github.com/tvdeyen))
- Use select2 for internal page link in link overlay [#1685](https://github.com/AlchemyCMS/alchemy_cms/pull/1685) ([tvdeyen](https://github.com/tvdeyen))
- Do not consider nested elements "orphaned" [#1684](https://github.com/AlchemyCMS/alchemy_cms/pull/1684) ([mamhoff](https://github.com/mamhoff))
- Destroy page-dependent elements [#1683](https://github.com/AlchemyCMS/alchemy_cms/pull/1683) ([mamhoff](https://github.com/mamhoff))
- Add anchor link tab to link overlay [#1682](https://github.com/AlchemyCMS/alchemy_cms/pull/1682) ([tvdeyen](https://github.com/tvdeyen))
- Ensure the apt/cache folder exists while installing [#1678](https://github.com/AlchemyCMS/alchemy_cms/pull/1678) ([tvdeyen](https://github.com/tvdeyen))
- Cache apt packages between CI runs [#1677](https://github.com/AlchemyCMS/alchemy_cms/pull/1677) ([tvdeyen](https://github.com/tvdeyen))
- Use select2 with AJAX search for essence page select [#1675](https://github.com/AlchemyCMS/alchemy_cms/pull/1675) ([tvdeyen](https://github.com/tvdeyen))
- Eager load associated records [#1674](https://github.com/AlchemyCMS/alchemy_cms/pull/1674) ([tvdeyen](https://github.com/tvdeyen))
- Add support for testing with multiple Rails versions [#1673](https://github.com/AlchemyCMS/alchemy_cms/pull/1673) ([tvdeyen](https://github.com/tvdeyen))
- Page api pagination [#1672](https://github.com/AlchemyCMS/alchemy_cms/pull/1672) ([tvdeyen](https://github.com/tvdeyen))
- Adjust select2 loading-more indicator [#1671](https://github.com/AlchemyCMS/alchemy_cms/pull/1671) ([tvdeyen](https://github.com/tvdeyen))
- Test support fixes [#1669](https://github.com/AlchemyCMS/alchemy_cms/pull/1669) ([tvdeyen](https://github.com/tvdeyen))
- Build fixes [#1668](https://github.com/AlchemyCMS/alchemy_cms/pull/1668) ([tvdeyen](https://github.com/tvdeyen))
- Add Menus [#1667](https://github.com/AlchemyCMS/alchemy_cms/pull/1667) ([tvdeyen](https://github.com/tvdeyen))
- Add a label component [#1666](https://github.com/AlchemyCMS/alchemy_cms/pull/1666) ([tvdeyen](https://github.com/tvdeyen))
- Run bundle install on CI even if cache hits [#1665](https://github.com/AlchemyCMS/alchemy_cms/pull/1665) ([tvdeyen](https://github.com/tvdeyen))
- Moves switch_language method into languages_controller. [#1664](https://github.com/AlchemyCMS/alchemy_cms/pull/1664) ([tvdeyen](https://github.com/tvdeyen))
- Cache gems between CI runs [#1663](https://github.com/AlchemyCMS/alchemy_cms/pull/1663) ([tvdeyen](https://github.com/tvdeyen))
- Remove production gems from local Gemfile [#1662](https://github.com/AlchemyCMS/alchemy_cms/pull/1662) ([tvdeyen](https://github.com/tvdeyen))
- Touch contents updated_at column in pure SQL [#1661](https://github.com/AlchemyCMS/alchemy_cms/pull/1661) ([tvdeyen](https://github.com/tvdeyen))
- Convert page editing user methods into AR relations [#1658](https://github.com/AlchemyCMS/alchemy_cms/pull/1658) ([tvdeyen](https://github.com/tvdeyen))
- Ensure the admin locale is only set by available locales [#1655](https://github.com/AlchemyCMS/alchemy_cms/pull/1655) ([tvdeyen](https://github.com/tvdeyen))
- Add a GitHub actions ci.yml [#1654](https://github.com/AlchemyCMS/alchemy_cms/pull/1654) ([tvdeyen](https://github.com/tvdeyen))
- Adjust install generator to latest changes [#1649](https://github.com/AlchemyCMS/alchemy_cms/pull/1649) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate _view suffix of element views [#1648](https://github.com/AlchemyCMS/alchemy_cms/pull/1648) ([tvdeyen](https://github.com/tvdeyen))
- Add a configurable logout method (default: delete) [#1647](https://github.com/AlchemyCMS/alchemy_cms/pull/1647) ([delphaber](https://github.com/delphaber))
- Deprecate render_essence helpers [#1644](https://github.com/AlchemyCMS/alchemy_cms/pull/1644) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate element editors [#1643](https://github.com/AlchemyCMS/alchemy_cms/pull/1643) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate local options in essence editors [#1642](https://github.com/AlchemyCMS/alchemy_cms/pull/1642) ([tvdeyen](https://github.com/tvdeyen))
- Ensure the EssencePage id regexp matches only numbers [#1641](https://github.com/AlchemyCMS/alchemy_cms/pull/1641) ([tvdeyen](https://github.com/tvdeyen))
- Use EssencePage in contact forms [#1640](https://github.com/AlchemyCMS/alchemy_cms/pull/1640) ([tvdeyen](https://github.com/tvdeyen))
- Add Alchemy::EssencePage [#1639](https://github.com/AlchemyCMS/alchemy_cms/pull/1639) ([tvdeyen](https://github.com/tvdeyen))
- FEAT: Render message and warnings in element editor [#1637](https://github.com/AlchemyCMS/alchemy_cms/pull/1637) ([tvdeyen](https://github.com/tvdeyen))
- Tackle Rails 6 deprecations [#1636](https://github.com/AlchemyCMS/alchemy_cms/pull/1636) ([tvdeyen](https://github.com/tvdeyen))
- Preload assets in tests [#1635](https://github.com/AlchemyCMS/alchemy_cms/pull/1635) ([tvdeyen](https://github.com/tvdeyen))
- Allow acts-as-list 1.0 [#1634](https://github.com/AlchemyCMS/alchemy_cms/pull/1634) ([tvdeyen](https://github.com/tvdeyen))
- Add Sprockets manifest file to dummy app [#1632](https://github.com/AlchemyCMS/alchemy_cms/pull/1632) ([tvdeyen](https://github.com/tvdeyen))
- Master now tracks 4.4.0.alpha [#1627](https://github.com/AlchemyCMS/alchemy_cms/pull/1627) ([tvdeyen](https://github.com/tvdeyen))
- Fix Cell Migration to maintain positions [#1625](https://github.com/AlchemyCMS/alchemy_cms/pull/1625) ([mamhoff](https://github.com/mamhoff))
- Cell Upgrader: Match quotation marks in cell name string [#1624](https://github.com/AlchemyCMS/alchemy_cms/pull/1624) ([mamhoff](https://github.com/mamhoff))
- Cell Migrator: Maintain element order in fixed elements [#1623](https://github.com/AlchemyCMS/alchemy_cms/pull/1623) ([mamhoff](https://github.com/mamhoff))
- Enhance cells upgrader to deal with render_elements from_page: x [#1622](https://github.com/AlchemyCMS/alchemy_cms/pull/1622) ([mamhoff](https://github.com/mamhoff))

## 4.3.2 (2019-11-08)

- Allow simple form 5 [#1660](https://github.com/AlchemyCMS/alchemy_cms/pull/1633) ([jkimmeyer](https://github.com/jkimmeyer))

## 4.3.1 (2019-09-27)

- Fix Cell Migration to maintain positions [#1625](https://github.com/AlchemyCMS/alchemy_cms/pull/1625) ([mamhoff](https://github.com/mamhoff))
- Cell Upgrader: Match quotation marks in cell name string [#1624](https://github.com/AlchemyCMS/alchemy_cms/pull/1624) ([mamhoff](https://github.com/mamhoff))
- Cell Migrator: Maintain element order in fixed elements [#1623](https://github.com/AlchemyCMS/alchemy_cms/pull/1623) ([mamhoff](https://github.com/mamhoff))
- Enhance cells upgrader to deal with render_elements from_page: x [#1622](https://github.com/AlchemyCMS/alchemy_cms/pull/1622) ([mamhoff](https://github.com/mamhoff))

## 4.3.0 (2019-08-23)

- Add Rails 6 support [#1616](https://github.com/AlchemyCMS/alchemy_cms/pull/1616) ([tvdeyen](https://github.com/tvdeyen))
- Use media_type over content_type in specs [#1615](https://github.com/AlchemyCMS/alchemy_cms/pull/1615) ([tvdeyen](https://github.com/tvdeyen))
- Remove unused Picture#security_token method [#1614](https://github.com/AlchemyCMS/alchemy_cms/pull/1614) ([tvdeyen](https://github.com/tvdeyen))
- rspec-rails 4 [#1613](https://github.com/AlchemyCMS/alchemy_cms/pull/1613) ([tvdeyen](https://github.com/tvdeyen))
- Update Dummy test app to Rails 5.2 [#1612](https://github.com/AlchemyCMS/alchemy_cms/pull/1612) ([tvdeyen](https://github.com/tvdeyen))
- add default styling for number inputs [#1598](https://github.com/AlchemyCMS/alchemy_cms/pull/1598) ([alexanderadam](https://github.com/alexanderadam))
- Upgrade responders to version 3.0.0 [#1593](https://github.com/AlchemyCMS/alchemy_cms/pull/1593) ([depfu](https://github.com/apps/depfu))
- Update jquery fileupload plugin [#1592](https://github.com/AlchemyCMS/alchemy_cms/pull/1592) ([tvdeyen](https://github.com/tvdeyen))
- Only return visible elements from Pages elements relations [#1590](https://github.com/AlchemyCMS/alchemy_cms/pull/1590) ([tvdeyen](https://github.com/tvdeyen))
- Only return visible elements from Elements nested_elements relation [#1589](https://github.com/AlchemyCMS/alchemy_cms/pull/1589) ([tvdeyen](https://github.com/tvdeyen))

## 4.2.3 (2019-09-27)

- Fix Cell Migration to maintain positions [#1625](https://github.com/AlchemyCMS/alchemy_cms/pull/1625) ([mamhoff](https://github.com/mamhoff))
- Cell Upgrader: Match quotation marks in cell name string [#1624](https://github.com/AlchemyCMS/alchemy_cms/pull/1624) ([mamhoff](https://github.com/mamhoff))
- Cell Migrator: Maintain element order in fixed elements [#1623](https://github.com/AlchemyCMS/alchemy_cms/pull/1623) ([mamhoff](https://github.com/mamhoff))
- Enhance cells upgrader to deal with render_elements from_page: x [#1622](https://github.com/AlchemyCMS/alchemy_cms/pull/1622) ([mamhoff](https://github.com/mamhoff))

## 4.2.2 (2019-08-13)

- Fallback to default locale if unavailable locale requested  [#1610](https://github.com/AlchemyCMS/alchemy_cms/pull/1610) ([mamhoff](https://github.com/mamhoff))

## 4.2.1 (2019-08-08)

- Use strings as JSON root keys in API controllers [#1602](https://github.com/AlchemyCMS/alchemy_cms/pull/1602) ([tvdeyen](https://github.com/tvdeyen))

## 4.2.0 (2019-05-30)

- remove unused .teatro.yml [#1585](https://github.com/AlchemyCMS/alchemy_cms/pull/1585) ([kirillshevch](https://github.com/kirillshevch))
- Use Set to collect callbacks in OnPageLayout [#1583](https://github.com/AlchemyCMS/alchemy_cms/pull/1583) ([mamhoff](https://github.com/mamhoff))
- Allow Ransack 1.x [#1580](https://github.com/AlchemyCMS/alchemy_cms/pull/1580) ([tvdeyen](https://github.com/tvdeyen))
- Set a max-width to preview frame [#1578](https://github.com/AlchemyCMS/alchemy_cms/pull/1578) ([tvdeyen](https://github.com/tvdeyen))
- Rebuild locked pages tabs in flexbox [#1577](https://github.com/AlchemyCMS/alchemy_cms/pull/1577) ([tvdeyen](https://github.com/tvdeyen))
- Use where.not instead of Arel [#1576](https://github.com/AlchemyCMS/alchemy_cms/pull/1576) ([tvdeyen](https://github.com/tvdeyen))
- Add missing requires to factories [#1575](https://github.com/AlchemyCMS/alchemy_cms/pull/1575) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade sqlite3 to version 1.4.1 [#1574](https://github.com/AlchemyCMS/alchemy_cms/pull/1574) ([depfu](https://github.com/apps/depfu))
- Fix elements window ajax errors [#1573](https://github.com/AlchemyCMS/alchemy_cms/pull/1573) ([tvdeyen](https://github.com/tvdeyen))
- Use SimpleForm field for datepicker in resources form [#1572](https://github.com/AlchemyCMS/alchemy_cms/pull/1572) ([tvdeyen](https://github.com/tvdeyen))
- Render warning message in warning helper [#1571](https://github.com/AlchemyCMS/alchemy_cms/pull/1571) ([tvdeyen](https://github.com/tvdeyen))
- Prohibit coffee-rails 5.0 [#1570](https://github.com/AlchemyCMS/alchemy_cms/pull/1570) ([tvdeyen](https://github.com/tvdeyen))
- Add Date column support to resources [#1567](https://github.com/AlchemyCMS/alchemy_cms/pull/1567) ([tvdeyen](https://github.com/tvdeyen))
- Fix pluralization of resource table header [#1566](https://github.com/AlchemyCMS/alchemy_cms/pull/1566) ([tvdeyen](https://github.com/tvdeyen))
- Fix compact elements style [#1565](https://github.com/AlchemyCMS/alchemy_cms/pull/1565) ([tvdeyen](https://github.com/tvdeyen))
- Show Ruby and Rails versions in info dialog [#1564](https://github.com/AlchemyCMS/alchemy_cms/pull/1564) ([tvdeyen](https://github.com/tvdeyen))
- Set spinner color to current text color [#1563](https://github.com/AlchemyCMS/alchemy_cms/pull/1563) ([tvdeyen](https://github.com/tvdeyen))
- Update links in post install message [#1562](https://github.com/AlchemyCMS/alchemy_cms/pull/1562) ([tvdeyen](https://github.com/tvdeyen))
- Allow cancancan 3 [#1561](https://github.com/AlchemyCMS/alchemy_cms/pull/1561) ([tvdeyen](https://github.com/tvdeyen))
- Fix Member Page permissions syntax [#1560](https://github.com/AlchemyCMS/alchemy_cms/pull/1560) ([tvdeyen](https://github.com/tvdeyen))
- Update upgrader [#1558](https://github.com/AlchemyCMS/alchemy_cms/pull/1558) ([tvdeyen](https://github.com/tvdeyen))
- Use element name local in generators [#1556](https://github.com/AlchemyCMS/alchemy_cms/pull/1556) ([tvdeyen](https://github.com/tvdeyen))
- Remove invalid bytecode handler [#1555](https://github.com/AlchemyCMS/alchemy_cms/pull/1555) ([tvdeyen](https://github.com/tvdeyen))
- Separate render element calls [#1554](https://github.com/AlchemyCMS/alchemy_cms/pull/1554) ([tvdeyen](https://github.com/tvdeyen))
- Expose the element into partials as local object [#1553](https://github.com/AlchemyCMS/alchemy_cms/pull/1553) ([tvdeyen](https://github.com/tvdeyen))
- Allow admins to switch all languages [#1552](https://github.com/AlchemyCMS/alchemy_cms/pull/1552) ([tvdeyen](https://github.com/tvdeyen))
- Raise targeted Ruby version to 2.3 [#1545](https://github.com/AlchemyCMS/alchemy_cms/pull/1545) ([tvdeyen](https://github.com/tvdeyen))
- Introduces an Elements finder class [#1544](https://github.com/AlchemyCMS/alchemy_cms/pull/1544) ([tvdeyen](https://github.com/tvdeyen))
- Fixate sqlite dep for bug fix [#1543](https://github.com/AlchemyCMS/alchemy_cms/pull/1543) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade shoulda-matchers to version 4.0.0 [#1542](https://github.com/AlchemyCMS/alchemy_cms/pull/1542) ([depfu](https://github.com/apps/depfu))
- Upgrade factory_bot_rails to version 5.0.1 [#1540](https://github.com/AlchemyCMS/alchemy_cms/pull/1540) ([depfu](https://github.com/apps/depfu))
- Use Flatpickr as Datepicker [#1533](https://github.com/AlchemyCMS/alchemy_cms/pull/1533) ([mamhoff](https://github.com/mamhoff))
- Use system tests over feature specs [#1528](https://github.com/AlchemyCMS/alchemy_cms/pull/1528) ([tvdeyen](https://github.com/tvdeyen))
- Flexible width for admin navigation entry labels [#1527](https://github.com/AlchemyCMS/alchemy_cms/pull/1527) ([tvdeyen](https://github.com/tvdeyen))
- Render new page when there is a flash message [#1525](https://github.com/AlchemyCMS/alchemy_cms/pull/1525) ([jedrekdomanski](https://github.com/jedrekdomanski))
- Responsive elements window and sidebar [#1519](https://github.com/AlchemyCMS/alchemy_cms/pull/1519) ([tvdeyen](https://github.com/tvdeyen))
- Change element eye icon on public state [#1517](https://github.com/AlchemyCMS/alchemy_cms/pull/1517) ([oniram88](https://github.com/oniram88))
- Maximize element window if Tinymce is fullscreen [#1515](https://github.com/AlchemyCMS/alchemy_cms/pull/1515) ([tvdeyen](https://github.com/tvdeyen))
- Remove cells in favour of fixed elements [#1514](https://github.com/AlchemyCMS/alchemy_cms/pull/1514) ([tvdeyen](https://github.com/tvdeyen))
- Feature: Autogenerate nestable elements [#1513](https://github.com/AlchemyCMS/alchemy_cms/pull/1513) ([tvdeyen](https://github.com/tvdeyen))
- Allow "data" key for module navigations [#1512](https://github.com/AlchemyCMS/alchemy_cms/pull/1512) ([mamhoff](https://github.com/mamhoff))
- Allow to define layout for page previews [#1500](https://github.com/AlchemyCMS/alchemy_cms/pull/1500) ([westonganger](https://github.com/westonganger))
- Disable page publish/view page buttons according to published_at [#1498](https://github.com/AlchemyCMS/alchemy_cms/pull/1498) ([westonganger](https://github.com/westonganger))
- Fix capitalization for login/logout/leave [#1497](https://github.com/AlchemyCMS/alchemy_cms/pull/1497) ([westonganger](https://github.com/westonganger))
- Verify controller keys within `register_module` [#1495](https://github.com/AlchemyCMS/alchemy_cms/pull/1495) ([westonganger](https://github.com/westonganger))
- Update bundled Tinymce to 4.8.3 [#1491](https://github.com/AlchemyCMS/alchemy_cms/pull/1491) ([tvdeyen](https://github.com/tvdeyen))
- Use dynamic attributes in factories [#1484](https://github.com/AlchemyCMS/alchemy_cms/pull/1484) ([tvdeyen](https://github.com/tvdeyen))
- Migrating to active_model_serializers ~> 0.10.0 [#1478](https://github.com/AlchemyCMS/alchemy_cms/pull/1478) ([pmashchak](https://github.com/pmashchak))
- Replace picture galleries with nestable elements [#1358](https://github.com/AlchemyCMS/alchemy_cms/pull/1358) ([tvdeyen](https://github.com/tvdeyen))
- Add a compact nested element style [#1357](https://github.com/AlchemyCMS/alchemy_cms/pull/1357) by [tvdeyen](https://github.com/tvdeyen)

## 4.1.0 (2018-09-22)

- Use console.warn for Alchemy.debug [#1476](https://github.com/AlchemyCMS/alchemy_cms/pull/1476) ([tvdeyen](https://github.com/tvdeyen))
- Fixes picture per page in overlay [#1475](https://github.com/AlchemyCMS/alchemy_cms/pull/1475) ([tvdeyen](https://github.com/tvdeyen))
- Style adjustments [#1474](https://github.com/AlchemyCMS/alchemy_cms/pull/1474) ([tvdeyen](https://github.com/tvdeyen))
- Simplify pagination implementation [#1471](https://github.com/AlchemyCMS/alchemy_cms/pull/1471) ([mamhoff](https://github.com/mamhoff))
- Try .any? to prevent error in dashboard on online users [#1469](https://github.com/AlchemyCMS/alchemy_cms/pull/1469) ([askl56](https://github.com/askl56))
- Update changelog for 4.0.4 release [#1468](https://github.com/AlchemyCMS/alchemy_cms/pull/1468) ([tvdeyen](https://github.com/tvdeyen))
- Do not cache sitemap in Turbolinks [#1463](https://github.com/AlchemyCMS/alchemy_cms/pull/1463) ([tvdeyen](https://github.com/tvdeyen))
- Fix sorting in Resources controller [#1462](https://github.com/AlchemyCMS/alchemy_cms/pull/1462) ([mamhoff](https://github.com/mamhoff))
- Fix removing picture essences [#1460](https://github.com/AlchemyCMS/alchemy_cms/pull/1460) ([mamhoff](https://github.com/mamhoff))
- Upgrade ransack to version 2.0.0 [#1458](https://github.com/AlchemyCMS/alchemy_cms/pull/1458) ([depfu](https://github.com/marketplace/depfu))
- Toolbar icon vertical alignment fixes [#1450](https://github.com/AlchemyCMS/alchemy_cms/pull/1450) ([tvdeyen](https://github.com/tvdeyen))
- Fix tidy task [#1449](https://github.com/AlchemyCMS/alchemy_cms/pull/1449) ([mamhoff](https://github.com/mamhoff))
- Update changelog [#1448](https://github.com/AlchemyCMS/alchemy_cms/pull/1448) ([tvdeyen](https://github.com/tvdeyen))
- New thumbnail style [#1447](https://github.com/AlchemyCMS/alchemy_cms/pull/1447) ([tvdeyen](https://github.com/tvdeyen))
- Styling fixes [#1446](https://github.com/AlchemyCMS/alchemy_cms/pull/1446) ([tvdeyen](https://github.com/tvdeyen))
- Do not prevent default click handling in Element editor [#1445](https://github.com/AlchemyCMS/alchemy_cms/pull/1445) ([mamhoff](https://github.com/mamhoff))
- Fix content container height [#1443](https://github.com/AlchemyCMS/alchemy_cms/pull/1443) ([tvdeyen](https://github.com/tvdeyen))
- Use max instead of sort.last in update check [#1442](https://github.com/AlchemyCMS/alchemy_cms/pull/1442) ([tvdeyen](https://github.com/tvdeyen))
- Use optional: true for optional belongs_to associations [#1441](https://github.com/AlchemyCMS/alchemy_cms/pull/1441) ([tvdeyen](https://github.com/tvdeyen))
- Set parent element id when pasting from clipboard [#1440](https://github.com/AlchemyCMS/alchemy_cms/pull/1440) ([tvdeyen](https://github.com/tvdeyen))
- Add must_revalidate to cache-control header [#1439](https://github.com/AlchemyCMS/alchemy_cms/pull/1439) ([afdev82](https://github.com/afdev82))
- Update README.md [#1438](https://github.com/AlchemyCMS/alchemy_cms/pull/1438) ([agorneo](https://github.com/agorneo))
- Add a pull request template [#1436](https://github.com/AlchemyCMS/alchemy_cms/pull/1436) ([tvdeyen](https://github.com/tvdeyen))
- Add a feature request template [#1435](https://github.com/AlchemyCMS/alchemy_cms/pull/1435) ([tvdeyen](https://github.com/tvdeyen))
- Add a GitHub issue template [#1434](https://github.com/AlchemyCMS/alchemy_cms/pull/1434) ([tvdeyen](https://github.com/tvdeyen))
- Picture zoom UX enhancements [#1431](https://github.com/AlchemyCMS/alchemy_cms/pull/1431) ([tvdeyen](https://github.com/tvdeyen))
- Fix draggable trash item feature [#1428](https://github.com/AlchemyCMS/alchemy_cms/pull/1428) ([tvdeyen](https://github.com/tvdeyen))
- Load Jcrop selection gif via asset pipeline [#1427](https://github.com/AlchemyCMS/alchemy_cms/pull/1427) ([tvdeyen](https://github.com/tvdeyen))
- Color and styles adjustments [#1426](https://github.com/AlchemyCMS/alchemy_cms/pull/1426) ([tvdeyen](https://github.com/tvdeyen))
- Extract tags css rules into own file [#1424](https://github.com/AlchemyCMS/alchemy_cms/pull/1424) ([tvdeyen](https://github.com/tvdeyen))
- Adjust the welcome screen to new color theme [#1423](https://github.com/AlchemyCMS/alchemy_cms/pull/1423) ([tvdeyen](https://github.com/tvdeyen))
- Fixes menubar layout [#1422](https://github.com/AlchemyCMS/alchemy_cms/pull/1422) ([tvdeyen](https://github.com/tvdeyen))
- Update jquery-ui-rails to 6.0 [#1420](https://github.com/AlchemyCMS/alchemy_cms/pull/1420) ([tvdeyen](https://github.com/tvdeyen))
- Allow CanCanCan 2.x [#1418](https://github.com/AlchemyCMS/alchemy_cms/pull/1418) ([tvdeyen](https://github.com/tvdeyen))
- Add a Heroku Deploy button [#1416](https://github.com/AlchemyCMS/alchemy_cms/pull/1416) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade simple_form to version 4.0 [#1413](https://github.com/AlchemyCMS/alchemy_cms/pull/1413) ([depfu](https://github.com/marketplace/depfu))
- Do not require localeapp gem [#1412](https://github.com/AlchemyCMS/alchemy_cms/pull/1412) ([tvdeyen](https://github.com/tvdeyen))
- Fix all Rubocop offenses and update some config [#1411](https://github.com/AlchemyCMS/alchemy_cms/pull/1411) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade mysql2 to version 0.5.1 [#1410](https://github.com/AlchemyCMS/alchemy_cms/pull/1410) ([depfu](https://github.com/marketplace/depfu))
- Capybara 3.0 support [#1409](https://github.com/AlchemyCMS/alchemy_cms/pull/1409) ([tvdeyen](https://github.com/tvdeyen))
- Handle zero plural resource names [#1407](https://github.com/AlchemyCMS/alchemy_cms/pull/1407) ([dbwinger](https://github.com/dbwinger))
- Update rubocop config [#1404](https://github.com/AlchemyCMS/alchemy_cms/pull/1404) ([tvdeyen](https://github.com/tvdeyen))
- Explicitly set the Rails version in dummy app [#1403](https://github.com/AlchemyCMS/alchemy_cms/pull/1403) ([tvdeyen](https://github.com/tvdeyen))
- Do not reload essence classes in dev mode [#1400](https://github.com/AlchemyCMS/alchemy_cms/pull/1400) ([tvdeyen](https://github.com/tvdeyen))
- Move all translations into `alchemy_i18n` extension [#1398](https://github.com/AlchemyCMS/alchemy_cms/pull/1398) ([tvdeyen](https://github.com/tvdeyen))
- Add `nested_elements` to serialized element json [#1397](https://github.com/AlchemyCMS/alchemy_cms/pull/1397) ([tvdeyen](https://github.com/tvdeyen))
- Fix YAML safe_load [#1395](https://github.com/AlchemyCMS/alchemy_cms/pull/1395) ([tvdeyen](https://github.com/tvdeyen))
- Fix passing html options to form builder submit input [#1394](https://github.com/AlchemyCMS/alchemy_cms/pull/1394) ([tvdeyen](https://github.com/tvdeyen))
- Darker blue dialogs [#1393](https://github.com/AlchemyCMS/alchemy_cms/pull/1393) ([tvdeyen](https://github.com/tvdeyen))
- New orange logo [#1392](https://github.com/AlchemyCMS/alchemy_cms/pull/1392) ([tvdeyen](https://github.com/tvdeyen))
- Use Open Sans for admin font [#1391](https://github.com/AlchemyCMS/alchemy_cms/pull/1391) ([tvdeyen](https://github.com/tvdeyen))
- Use ActiveRecord touching [#1390](https://github.com/AlchemyCMS/alchemy_cms/pull/1390) ([tvdeyen](https://github.com/tvdeyen))
- correct scss typo [#1388](https://github.com/AlchemyCMS/alchemy_cms/pull/1388) ([oniram88](https://github.com/oniram88))
- Add Rails 5.2 support [#1387](https://github.com/AlchemyCMS/alchemy_cms/pull/1387) ([tvdeyen](https://github.com/tvdeyen))
- Update Gutentag [#1386](https://github.com/AlchemyCMS/alchemy_cms/pull/1386) ([tvdeyen](https://github.com/tvdeyen))
- Fix resources search [#1384](https://github.com/AlchemyCMS/alchemy_cms/pull/1384) ([tvdeyen](https://github.com/tvdeyen))
- Fixate Gutentag to 2.1.0 for now [#1383](https://github.com/AlchemyCMS/alchemy_cms/pull/1383) ([tvdeyen](https://github.com/tvdeyen))
- Skip migrate-to-gutentag migration for fresh installs [#1381](https://github.com/AlchemyCMS/alchemy_cms/pull/1381) ([tvdeyen](https://github.com/tvdeyen))
- More prominent active menu color [#1380](https://github.com/AlchemyCMS/alchemy_cms/pull/1380) ([tvdeyen](https://github.com/tvdeyen))
- Use at least jquery-rails 4.0.4 [#1378](https://github.com/AlchemyCMS/alchemy_cms/pull/1378) ([tvdeyen](https://github.com/tvdeyen))
- Give capybara more time to render pictures [#1377](https://github.com/AlchemyCMS/alchemy_cms/pull/1377) ([tvdeyen](https://github.com/tvdeyen))
- A few admin layout refinements [#1374](https://github.com/AlchemyCMS/alchemy_cms/pull/1374) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade cancancan to version 2.1 [#1372](https://github.com/AlchemyCMS/alchemy_cms/pull/1372) ([depfu](https://github.com/apps/depfu))
- Upgrade kaminari to version 1.1 [#1370](https://github.com/AlchemyCMS/alchemy_cms/pull/1370) ([depfu](https://github.com/apps/depfu))
- Remove all old migration files [#1367](https://github.com/AlchemyCMS/alchemy_cms/pull/1367) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade mysql2 to version 0.4.10 [#1366](https://github.com/AlchemyCMS/alchemy_cms/pull/1366) ([depfu](https://github.com/marketplace/depfu))
- Upgrade pg to version 1.0.0 [#1365](https://github.com/AlchemyCMS/alchemy_cms/pull/1365) ([depfu](https://github.com/marketplace/depfu))
- Use Gutentag for tags [#1364](https://github.com/AlchemyCMS/alchemy_cms/pull/1364) ([tvdeyen](https://github.com/tvdeyen))
- Update Rubocop config [#1363](https://github.com/AlchemyCMS/alchemy_cms/pull/1363) ([tvdeyen](https://github.com/tvdeyen))
- Compress 4.0 migrations [#1362](https://github.com/AlchemyCMS/alchemy_cms/pull/1362) ([tvdeyen](https://github.com/tvdeyen))
- Removes 3.x upgraders [#1361](https://github.com/AlchemyCMS/alchemy_cms/pull/1361) ([tvdeyen](https://github.com/tvdeyen))
- Get rid of Rails 5.2 deprecations [#1360](https://github.com/AlchemyCMS/alchemy_cms/pull/1360) ([tvdeyen](https://github.com/tvdeyen))
- Fix API response for users able to edit content [#1356](https://github.com/AlchemyCMS/alchemy_cms/pull/1356) ([tvdeyen](https://github.com/tvdeyen))
- Remove jasmine gems [#1355](https://github.com/AlchemyCMS/alchemy_cms/pull/1355) ([tvdeyen](https://github.com/tvdeyen))
- Remove translations provided by ActiveModel [#1354](https://github.com/AlchemyCMS/alchemy_cms/pull/1354) ([pelargir](https://github.com/pelargir))
- Update bundled TinyMCE to 4.7.5 [#1353](https://github.com/AlchemyCMS/alchemy_cms/pull/1353) ([tvdeyen](https://github.com/tvdeyen))
- New color theme [#1352](https://github.com/AlchemyCMS/alchemy_cms/pull/1352) ([tvdeyen](https://github.com/tvdeyen))
- Only scroll to element if focused from preview [#1351](https://github.com/AlchemyCMS/alchemy_cms/pull/1351) ([tvdeyen](https://github.com/tvdeyen))
- Don't prevent submit event of element save button [#1349](https://github.com/AlchemyCMS/alchemy_cms/pull/1349) ([tvdeyen](https://github.com/tvdeyen))
- Use FA calendar icons for EssenceDate picker [#1348](https://github.com/AlchemyCMS/alchemy_cms/pull/1348) ([tvdeyen](https://github.com/tvdeyen))
- Use headless chrome for feature tests [#1347](https://github.com/AlchemyCMS/alchemy_cms/pull/1347) ([tvdeyen](https://github.com/tvdeyen))
- Refactor the preview window JS code [#1346](https://github.com/AlchemyCMS/alchemy_cms/pull/1346) ([tvdeyen](https://github.com/tvdeyen))
- New table styles [#1344](https://github.com/AlchemyCMS/alchemy_cms/pull/1344) ([tvdeyen](https://github.com/tvdeyen))
- Remove pleaseWait overlay from links with GET requests [#1343](https://github.com/AlchemyCMS/alchemy_cms/pull/1343) by [tvdeyen](https://github.com/tvdeyen)
- Replaces PNG icons with FontAwesome icon font [#1342](https://github.com/AlchemyCMS/alchemy_cms/pull/1342) by [tvdeyen](https://github.com/tvdeyen)
- Ensure to use pg < 1.0 in tests [#1341](https://github.com/AlchemyCMS/alchemy_cms/pull/1341) ([tvdeyen](https://github.com/tvdeyen))
- Add must_revalidate to cache-control header [#1340](https://github.com/AlchemyCMS/alchemy_cms/pull/1340) ([afdev82](https://github.com/afdev82))
- Removed fixed table headers from admin resource tables [#1339](https://github.com/AlchemyCMS/alchemy_cms/pull/1339) by [tvdeyen](https://github.com/tvdeyen)
- Removed Bourbon Sass library [#1339](https://github.com/AlchemyCMS/alchemy_cms/pull/1339) by [tvdeyen](https://github.com/tvdeyen)
- Add possibility to add a suffix to the page title [#1331](https://github.com/AlchemyCMS/alchemy_cms/pull/1331) ([jrieger](https://github.com/jrieger))
- Do not add leading slash to default admin path [#1329](https://github.com/AlchemyCMS/alchemy_cms/pull/1329) ([tvdeyen](https://github.com/tvdeyen))
- Check if file exists on disk before calling identify [#1327](https://github.com/AlchemyCMS/alchemy_cms/pull/1327) ([chalmagean](https://github.com/chalmagean))
- Skip folded deeper levels when rendering page tree [#1324](https://github.com/AlchemyCMS/alchemy_cms/pull/1324) ([pascalj](https://github.com/pascalj))

## 4.0.5 (2018-09-17)

- Do not cache sitemap in Turbolinks [#1463](https://github.com/AlchemyCMS/alchemy_cms/pull/1463) ([tvdeyen](https://github.com/tvdeyen))
- Skip folded deeper levels when rendering page tree [#1324](https://github.com/AlchemyCMS/alchemy_cms/pull/1324) ([pascalj](https://github.com/pascalj))

## 4.0.4 (2018-09-05)

- Allow Kaminari 1.x [#1467](https://github.com/AlchemyCMS/alchemy_cms/pull/1467) ([tvdeyen](https://github.com/tvdeyen))

## 4.0.3 (2018-05-14)

- Add must_revalidate to cache-control header [#1340](https://github.com/AlchemyCMS/alchemy_cms/pull/1340) ([afdev82](https://github.com/afdev82))

## 4.0.2 (2018-05-08)

- Fix draggable trash item feature [#1429](https://github.com/AlchemyCMS/alchemy_cms/pull/1429) ([tvdeyen](https://github.com/tvdeyen))
- Allow CanCanCan 2.x [#1418](https://github.com/AlchemyCMS/alchemy_cms/pull/1418) ([tvdeyen](https://github.com/tvdeyen))

## 4.0.1 (2018-04-23)

- Add more classes to YAML.safe_load [#1414](https://github.com/AlchemyCMS/alchemy_cms/pull/1414) ([tvdeyen](https://github.com/tvdeyen))

## 4.0.0 (2017-11-06)

- Fixes image cropping issues [#1320](https://github.com/AlchemyCMS/alchemy_cms/pull/1320) and [#1321](https://github.com/AlchemyCMS/alchemy_cms/pull/1321) by [tvdeyen](https://github.com/tvdeyen)
  This includes the change that images will not be cropped anymore unless `crop: true` is explicitly given in either the contents settings or passed via options to `render_essence`. The former behavior of implicitly cropping only because crop values (`crop_from` or `crop_size`) were present on the `EssencePicture` database record was erroneous and confusing.
- Allow Dragonfly 1.1 and above [#1314](https://github.com/AlchemyCMS/alchemy_cms/pull/1314) by [tvdeyen](https://github.com/tvdeyen)
- Added Rails 5.1 support [#1310](https://github.com/AlchemyCMS/alchemy_cms/pull/1310) by [tvdeyen](https://github.com/tvdeyen)
- Always use `border-box` box model for all CSS components in the admin [#1309](https://github.com/AlchemyCMS/alchemy_cms/pull/1309) by [tvdeyen](https://github.com/tvdeyen)

## 4.0.0.rc2 (2017-08-18)

- Removed deprecated `:image_size` option from `EssencePicture`
  Use `:size` instead.
- Remove deprecated `take_me_for_preview` content definition option
  Use `as_element_title` instead.
- Removed deprecated picture url helpers `show_alchemy_picture_path` and `show_alchemy_picture_url`
  Use `picture.url` instead.
- Removed deprecated pages helper module.
- Removed deprecated translation methods `_t` and `Alchemy::I18n.t`.
  Use `Alchemy.t` instead.
- Removed deprecated `redirect_index` configuration
  Use `redirect_to_public_child` configuration instead.

## 4.0.0.rc1 (2017-08-17)

- Removed `merge_params` from `Alchemy::Admin::BaseHelper`
  Use `ActionController::Parameters#merge` instead
- Removed `merge_params_only` from `Alchemy::Admin::BaseHelper`
  Use methods from `ActionController::Parameters` instead
- Removed `merge_params_without` from `Alchemy::Admin::BaseHelper`
  Use `ActionController::Parameters#delete_if` instead
- Removed `tag_list_tag_active?` from `Alchemy::Admin::TagsHelper`
  Use `filtered_by_tag?` instead
- Removed `add_to_tag_filter` and `remove_from_tag_filter` from `Alchemy::Admin::TagsHelper`
  Use `tags_for_filter` and pass the `current` tag instead
- Removes the possibility to pass options param as JSON string. [#1291](https://github.com/AlchemyCMS/alchemy_cms/pull/1291) by [tvdeyen](https://github.com/tvdeyen)
  Pass normal params instead.
- Removed `redirect_back_or_to_default` from `Alchemy::Admin::BaseController`
  Use Rails' `redirect_back` with a `fallback_location` instead
- Deprecated controller requests test helpers [#1284](https://github.com/AlchemyCMS/alchemy_cms/pull/1284) by [tvdeyen](https://github.com/tvdeyen)

## 4.0.0.beta (2017-06-20)

- Rails 5

## 3.6.5 (2018-05-08)

- Fix draggable trash item feature [#1430](https://github.com/AlchemyCMS/alchemy_cms/pull/1430) ([tvdeyen](https://github.com/tvdeyen))

## 3.6.4 (2018-04-23)

- Add more classes to YAML.safe_load [#1396](https://github.com/AlchemyCMS/alchemy_cms/pull/1396) ([tvdeyen](https://github.com/tvdeyen))

## 3.6.3 (2017-10-24)

- Remove `:display` cancan alias [#1318](https://github.com/AlchemyCMS/alchemy_cms/pull/1318) by [tvdeyen](https://github.com/tvdeyen)

## 3.6.2 (2017-09-01)

- Handle custom errors in `Alchemy::Picture#url` [#1305](https://github.com/AlchemyCMS/alchemy_cms/pull/1305) by [tvdeyen](https://github.com/tvdeyen)
- Do not move elements in tidy cells task [#1303](https://github.com/AlchemyCMS/alchemy_cms/pull/1303) by [tvdeyen](https://github.com/tvdeyen)
- Add a store image file format rake task [#1302](https://github.com/AlchemyCMS/alchemy_cms/pull/1302) by [tvdeyen](https://github.com/tvdeyen)

## 3.6.1 (2017-08-16)

- Do not ask `systempage?` everytime we load the page definition [#1239](https://github.com/AlchemyCMS/alchemy_cms/pull/1283) by [tvdeyen](https://github.com/tvdeyen)
  This speeds up rendering large sitemaps by about 6 times.

## 3.6.0 (2017-06-20)

__Notable Changes__

- The seeder does not generate default site and root page anymore (#1239) by tvdeyen
  Alchemy handles this auto-magically now. No need to run `Alchemy::Seeder.seed!` any more |o/
- Security: Sanitize ActiveRecord queries in `Alchemy::Element`, `Alchemy::Page` and
  `Alchemy::PagesHelper` (#1257) by jessedoyle
- Remove post install message reference to the `alchemy` standalone installer (#1256) by jessedoyle
- Fixes tag filtering for pictures and attachments in overlay (#1266) by robinboening
- Fix js error on page#update with single quote in page name (#1263) by robinboening
- Change meta charset from 'utf8' to 'utf-8' (#1253) by rbjoern84
- Render "text" as type for datepicker input fields (#1246) by robinboening
- Remove unused Page attr_accessors (#1240) by tvdeyen
- Permit search params while redirecting in library (#1236) by tvdeyen
- Only allow floats and ints as fixed ratio for crop (#1234) by tvdeyen
- Use at least dragonfly 1.0.7 (#1225) by tvdeyen
- Add handlebars-assets gem (#1203) by tvdeyen
- Add a new spinner animation (#1202) by tvdeyen
- Re-color the Turbolinks progressbar (#1199) by tvdeyen
- Use normal view for pages sort action (#1197) by tvdeyen
- Add srcset and sizes support for EssencePicture (#1193) by tvdeyen

## 3.5.0 (2016-12-22)

__New Features__

- New API endpoint for retrieving a nested page tree (#1155)
  `api/pages/nested` returns a nested JSON tree of all pages.
- Add page and user seeding support (#1160)
- Files of attachments are replaceable now (#1167)
- Add fixed page attributes (#1168)
  Page attributes can be defined as fixed_attributes to prevent changes by the user.
- Allow to declare which user role can edit page content on the page layout level.

__Notable Changes__

- Removed the standalone installer (#1206)
- The essence date input field is now 100% width (#1191)
- The essence view partials don't get cached anymore (#1099)
- The essence editor partials don't get cached anymore (#1171)
- Removes update_essence_select_elements (#1103)
- The admin resource form now uses the datetime-picker instead of the date-picker for datetime fields.
- The `preview_mode_code` helper is moved to a partial in `alchemy/preview_mode_code`. (#1110)
- The `render_meta_data` helper is moved to a partial in `alchemy/pages/meta_data` and can be rendered with the same options as before but now passed in as locals. (#1110)
- The view helpers `preview_mode_code`, `render_meta_data`, `render_meta_tag`, `render_page_title`, `render_title_tag` are now deprecated. (#1110)
- An easy way to include several edit mode related partials is now available (#1120):
  `render 'alchemy/edit_mode'` loads `menubar` and `preview_mode_code` at once
- Add support for Turbolinks 5.0 (#1095)
- Use Dragonfly middleware to render pictures and remove our custom solution (#1084)
- `image_size` option is now deprecated. Please use just `size` (#1084)
- `show_alchemy_picture_path` helper is now deprecated. Please use `picture.url` instead (#1084)
- Display download information on the Attachment Modal Dialog (#1137)
- Added foreign keys to important associations (#1149)
- Also destroy trashed elements when page gets destroyed (#1149)
- Upgrade tasks can now be run separately (#1152)
- Update to Tinymce 4.4.3
- New sitemap UI (#1172)
- Removed picture cache flushing (#1185)
- Removed Mountpoint class (#1186)

__Fixed Bugs__

- Fix setting of locale when `current_alchemy_user.language` doesn't return a Symbol (#1097)
- Presence validation of EssenceFile is not working (#1096)
- Allow to define unique nestable elements (#852)

## 3.4.2 (2016-12-22)

__Notable Changes__

- Allow users to manually publish changes on global pages

__Fixed Bugs__

- The `language_links` helper now only renders languages from the current site

## 3.4.1 (2016-08-31)

__Fixed Bugs__

- Remove trailing new lines in the AddImageFileFormatToAlchemyPictures migration. (#1107)
  If you migrated already, use the `alchemy:upgrade:fix_picture_format` rake task.
- Don't overwrite the fallback options when rendering a picture (#1113)
- Fixes the messages mailer views generator (#1118)

## 3.4.0 (2016-08-02)

__New Features__

- `MessagesMailer` (formerly known as `Messages`) now inherits from `ApplicationMailer`
when it is defined.
- Adds time based published pages: The public status of a page is now made of two time stamps:
  `public_on` and `public_until`
- Send page expiration cache headers
- Adds an +EssencePictureView+ class responsible for rendering the `essence_picture_view` partial
- Adds a file type filter to file archive
- Allow setting the type of EssenceText input fields in the elements.yml via `settings[:input_type]`
- Adds support for defining custom searchable attributes in resources
- Automatically add tag management to admin module views, when the resource model
  has been set to `acts_as_taggable`.
- Automatically add scope filters to admin module views, when the resource model
  has the class method `alchemy_resource_filters` defined.

__Notable Changes__

- `Messages` mailer class has been renamed to `MessagesMailer`
- Removed the auto-magically merge of Ability classes (#1022)
- Replace jQueryUI datepicker with $.datetimepicker
- Thumbnails now render in original file format, but GIFs will always be flattened
- Pictures will be rendered in original file format by default
- Allow SVG files to be rendered as EssencePicture
- When using Alchemy content outside of Alchemy, `current_ability` is no longer
  included with `Alchemy::ControllerActions` to prevent method clashes. If you
  need access to `current_ability` you also need to include `Alchemy::AbilityHelper`
- Asset manifests are now installed into `vendor/assets` folder in order to provide easy customization
  Please don't use alchemy/custom files any more. Instead require your customizations in the manifests.
- Removes the default_scope from Language on_site current while ensuring to load languages by code
  from current site only.
- Removes the `Language.get_default` method alias for `Language.default`
- Move site select into pages and languages module to avoid confusion about curent site (#1067)
- List pages from all sites in currently locked pages tabs and Dashboard widget (#1067)
- The locked value on page is now a timestamp (`locked_at`), so we can order locked pages by (#1070)
- Persist user in dummy app
- When publishing a page with the publish button, `Page#public_on` does not get
  reset to the current time when it is already set and in the past, and
  `Page#public_until` does not get nilled when it is in the future.

__Fixed Bugs__

- Fix table width for attachments and resources on small window sizes.
- Generators don't delete directories any more (#850)
- Some elements crashed the backend's JS when being saved (#1091)

## 3.3.3 (2016-09-11)

- Fix bug that rendered duplicate nested elements within a cell after copying a parent element.

## 3.3.2 (2016-08-02)

- Use relative url for page preview frame in order to prevent cross origin errors (#1076)

## 3.3.1 (2016-06-20)

- Fix use of Alchemy::Resource with namespaced models (#729)
- Allow setting the type of EssenceText input fields in the elements.yml via `settings[:input_type]`
- Admin locale switching does not switch language tree any more (#1065)
- Fixes bug where old site session causes not found errors (#1047)
- Fix inability to add nested elements on pages with cells (#1039)
- Skip upgrader if no element definitions are found (#1060)
- Fix selecting the active cell for elements with nested elements (#1041)

## 3.3.0 (2016-05-18)

__New Features__

- Add support for Sprockets 3
- Add support for jquery-rails 4.1
- Show a welcome page, if no users or pages are present yet
- Namespace spec files
- Image library slideshow
- Global "current locked pages" tabs
- New option `linkable: false` for `EssencePicture`
- Allow custom routing for admin backend
- Resource forms can now have Tinymce enabled by adding `.tinymce` class
- `Alchemy::EssenceFile` now has a `link_text` attribute, so the editor is able to change the linked text of the download link.
- Enable to pass multiple page layout names to `on_page_layout` callbacks
- Client side rendering of the pages admin
- Deprecate `redirect_index` configuration
- Add Nestable elements feature
- Default site in seeder is now configurable
- Frontpage name and page layout are now editable when creating new language trees

__Notable Changes__

- Essence generator does not namespace the model into `Alchemy` namespace anymore
- New simplified uploader that allows to drag and drop images onto the archive everywhere in your app
  - Model names in uploader `allowed_filetypes` setting are now namespaced.
    Please be sure to run `rake alchemy:upgrade` to update your settings.
- Allow uppercase country codes
- Uses Time.current instead of Time.now for proper timezone support
- Adds year to `created_at` column of attachments table
- Removes "available contents" feature.
- Use Ransack for Admin Resources filtering, sorting and searching
- Renames Alchemy translation helpers from `_t` to `Alchemy.t`
- Do not append geometry string to preprocess option
- Skip the default locale in urls
- Add a proper index route and do not redirect to page anymore
- Updates Tinymce to 4.2.3
- Moves page status info into reusable partial
- Refactors factories into individual requirable files
- Do not raise error if `element_ids` params is missing while ordering elements
- Removes old middleware for rescueing legacy sessions
- Use rails tag helpers instead of plain HTML for meta tags
- Remove the duplication of `#decription` vs. `#definition`
- Resource CSV export now includes ID column and does not truncate large text columns anymore
- `Alchemy::Attachment#urlname` now returns always an escaped urlname w/o format suffix and does not convert the `file_name` once on create anymore
- Speed up the admin interface significantly when handling a large amount of pages

__Fixed Bugs__

- Add `locale` to `Alchemy::Language` to avoid errors for languages with missing locale files #831
- Fixes `Alchemy::PageLayout.get_all_by_attributes`
- Fix tag list display in picture library
- Animated GIFs display correctly
- EssenceSelect grouped options tags
- Add missing element partials for dummy app
- Eliminate an SQL lookup on frontend cached element partials
- Add missing german and spanish translation for element toolbar
- Use the site_id parameter and the session only in the Admin area
- Render 404 if accessing an unpublished index page that has "on page layout" callbacks

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.2.1...v3.3.0)

## 3.2.1 (2016-03-31)

__Fixed Bugs__

- Fix constant lookup issues with registered abilites
- Fix: `EssenceSelect` grouped `select_values`
- Respect `:reverse` option when sorting elements
- Directly updates position in database while sorting contents
- Don't show trashed elements when using a fallback
- Fixes wrong week number in datepicker

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.2.0...v3.2.1)

## 3.2.0 (2015-07-31)

[Release Notes](https://github.com/AlchemyCMS/alchemy_cms/releases/tag/v3.2.0)

## 3.1.3 (2016-01-21)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.1.1...v3.1.3)

## 3.1.2 (yanked)

No changes

## 3.1.1 (2015-03-17)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.1.0...v3.1.1)

## 3.1.0 (2015-02-24)

[Release Notes](https://github.com/AlchemyCMS/alchemy_cms/releases/tag/v3.1.0)

## 3.0.4 (2015-03-17)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.0.3...v3.0.4)

## 3.0.3 (2014-12-24)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.0.2...v3.0.3)

## 3.0.2 (2014-09-30)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.0.1...v3.0.2)

## 3.0.1 (2014-09-11)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.0.0...v3.0.1)

## 3.0.0 (2014-07-03)

[Release Notes](https://github.com/AlchemyCMS/alchemy_cms/releases/tag/v3.0.0)
