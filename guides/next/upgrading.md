---
prev:
  text: Deployment
  link: /next/deployment
next: false
---

# Updating Alchemy

This guide describes how to update AlchemyCMS to a new version.

<ServiceAd href="https://blish.cloud/en/solutions/alchemycms">
<template #before>Need help upgrading? Our sponsor</template>
<template #after>offers professional <a href="https://blish.cloud/en/solutions/alchemycms" target="_blank">Alchemy upgrade services</a>.</template>
</ServiceAd>

## Update the Gem

Update the version constraint in your `Gemfile` and run bundler.

~~~ diff
-gem 'alchemy_cms', '~> 8.0'
+gem 'alchemy_cms', '~> 8.1'
~~~

If you use [alchemy-devise](extensions#alchemy-devise) for authentication, update it as well. The major and minor versions of `alchemy_cms` and `alchemy-devise` match.

~~~ diff
-gem 'alchemy_cms', '~> 8.0'
+gem 'alchemy_cms', '~> 8.1'
-gem 'alchemy-devise', '~> 8.0'
+gem 'alchemy-devise', '~> 8.1'
~~~

Then run bundler.

~~~ bash
bundle update alchemy_cms alchemy-devise
~~~

## Run the Upgrade Task

The upgrade task runs all necessary migrations and adjustments.

~~~ bash
bin/rails alchemy:upgrade
~~~

Follow the on-screen instructions. The task will inform you about changes and any manual steps required.

If you have `alchemy-devise` installed, re-run its install generator to pick up any changes.

~~~ bash
bin/rails g alchemy:devise:install
~~~

### Run Individual Upgrade Tasks

Upgrade tasks can also be run individually. For example, to run only the config upgrade:

~~~ bash
bin/rails alchemy:upgrade:config
~~~

List all available upgrade tasks with:

~~~ bash
bin/rails -T alchemy:upgrade
~~~

## Follow-ups

Most of the time the upgrader handles everything. But some upgrades require manual steps — these are listed as TODOs at the end of the upgrade output. Follow them carefully.

## Major Version Upgrades

Major versions follow the same upgrade process, but include breaking changes. They remove deprecated features and old upgrade tasks.

::: warning
Before upgrading to the next major version, make sure you have addressed all deprecation warnings and run all upgrade tasks in the current version first.
:::

### Upgrading to Alchemy 9.0 <Badge type="tip" text="9.0+" />

Upgrade to Alchemy 8.4 and run its upgrade task before you upgrade to 9.0. Alchemy 9.0 removes the 8.x upgrade tasks and combines all previous migrations into one, so apps coming from an older version would miss them.

Alchemy 9.0 removes everything that was deprecated for removal in 9.0. Fix all deprecation warnings your app logs on Alchemy 8.4 first, because the removed APIs fail without a warning on 9.0.

#### Gem Versions

`alchemy-devise` and `alchemy_i18n` are now developed in the `alchemy_cms` repository and released together with it. Each requires the exact same `alchemy_cms` version, so update all of them at once:

~~~ ruby
gem "alchemy_cms", "~> 9.0"
gem "alchemy-devise", "~> 9.0"
gem "alchemy_i18n", "~> 9.0"
~~~

#### What the Upgrade Task Does

Besides updating the configuration and running the migrations, `bin/rails alchemy:upgrade` runs these 9.0 tasks:

| Task | What it does |
| ---- | ------------ |
| `alchemy:upgrade:9.0:upgrade_menu_positions` | Rewrites menu entries with a `position` into `config.menu.insert` calls |
| `alchemy:upgrade:9.0:migrate_ingredient_editor_partials` | Moves ingredient editor partials into editor components |
| `alchemy:upgrade:9.0:remove_deprecated_columns` | Asks whether to remove database columns Alchemy ignores |

Each task lists what it could not do automatically as a TODO. The following sections explain the changes behind them and what is left for you to do.

#### Menu Entry Positions

The admin navigation lists its entries in the order of `Alchemy.config.menu`. The `position` of menu entries has been removed. The upgrade task rewrites `config.menu.add` calls with a literal position into `config.menu.insert` calls in your initializers. Check the order of your entries afterwards and move any position it could not rewrite by hand, as described in [Migrating from `position`](how_to_create_modules#migrating-from-position).

#### Ingredient Editor Partials

Ingredient editors are rendered by view components only. Partials like `app/views/alchemy/ingredients/_my_ingredient_editor.html.erb` are not rendered anymore, together with the `Alchemy::IngredientEditor` object they received, the `element_form` local and the `ingredient_label` and `render_ingredient_role` helpers.

The upgrade task moves each ERB partial into the template of a new `Alchemy::Ingredients::MyIngredientEditor` component and rewrites it:

- Methods of the former `my_ingredient_editor` local are methods of the component now, e.g. `form_field_id`. Everything else is called on `ingredient`.
- `element_form.fields_for(:ingredients, ...)` becomes `fields_for` with the ingredient's form field name, plus the hidden `ingredient_id_field`.
- `ingredient_label(my_ingredient_editor)` becomes `ingredient_label`.

Review the generated templates and add `<%= validation_error %>` where validation errors of the ingredient should show up. Many partials only replaced the input of the default editor. For these, consider deleting the template and overriding `input_field` in the component instead, which keeps the label, hint and validation error of the default editor. See [The Editor Component](how_to_create_custom_ingredients#the-editor-component).

The upgrade task cannot migrate partials that are not ERB, that override one of Alchemy's built-in editors or whose component already exists. It generates an editor component for non-ERB partials to start from and lists all of them as a TODO.

#### Admin JavaScript Translations

The admin JavaScript reads its translations from the `alchemy.javascript` namespace of your locale files. The `app/views/alchemy/admin/translations/_<locale>.js` partials are not rendered anymore. If your app overrides one, Alchemy logs a deprecation warning. Move its keys into your locale file:

~~~ yaml
# config/locales/alchemy.de.yml
de:
  alchemy:
    javascript:
      cancel: "Abbrechen"
~~~

Keys missing from a locale fall back to English. The admin no longer defines a global `Alchemy` object, so scripts that read `Alchemy.translations` or expect `window.Alchemy` to exist need to be changed.

#### Sitemap Template

The sitemap template moved from `alchemy/pages/sitemap` to `alchemy/sitemap/show`. An override at the old path keeps working with a deprecation warning until Alchemy 10.0. Move it to `app/views/alchemy/sitemap/show.xml.erb`. Routes pointing `/sitemap.xml` to `Alchemy::PagesController#sitemap` have to point to `alchemy/sitemap#show` instead.

#### Removed APIs

These APIs were deprecated in Alchemy 8.x and have been removed:

| Removed | Use instead |
| ------- | ----------- |
| `Alchemy::Config`, module level accessors like `Alchemy.preview_sources` | `Alchemy.config`, e.g. `Alchemy.config.preview_sources` |
| `Alchemy.user_class`, `Alchemy.login_path` and the other auth accessors | `Alchemy.config.user_class`, `Alchemy.config.login_path`, ... |
| `Alchemy.register_ability` | `Alchemy.config.abilities.add("MyAbility")` |
| `Alchemy.enable_searchable` | `Alchemy.config.show_page_searchable_checkbox` |
| `configuration(:name)` controller and view helper | `Alchemy.config.get(:name)` |
| `Alchemy.config.output_image_jpg_quality` | `Alchemy.config.output_image_quality` |
| `Alchemy::Modules.register_module` | `Alchemy.config.menu.add`, see [Migrating from `register_module`](how_to_create_modules#migrating-from-register-module) |
| `alchemy_main_navigation_entry`, `url_for_module`, `sorted_alchemy_modules` | `Alchemy::Admin::MainNavigation::Entry`, `Alchemy::Configurations::MenuItem#path`, `Alchemy.config.menu` |
| `Alchemy::Logger.warn` with a second argument, `log_warning` | `Alchemy::Logger.warn(message)` |
| `alchemy/menubar` partial | `render Alchemy::Menubar.new` |
| `alchemy/admin/uploader/button` partial | `render Alchemy::Admin::UploaderButton.new` |
| `current_alchemy_user_name` helper | `render Alchemy::Admin::CurrentUserName.new` |
| `admin/dashboard/info` route | `Alchemy::Admin::Dashboard::Widgets::SystemInfo` |
| `Page#title=`, `Page#meta_description=`, `Page#meta_keywords=` | The same setters on `page.draft_version` |
| `Picture#suffix` | `Picture#image_file_extension` |
| `Element.hidden`, `PageVersion.drafts` | `.draft` |
| `PageVersion.public_on` | `PageVersion.published` |
| `Node.available_to_members` | `Node.available_to(user)` |
| `Alchemy::PagesController#sitemap` | `Alchemy::SitemapController#show` |
| A user class `admins` scope as fallback | Include `Alchemy::UserMethods` into your user class |
| `alchemy_resource_filters` in resource models | `add_alchemy_filter` in the controller and `ransackable_scopes` in the model |
| `select2` and `select2_search` Capybara helpers | `tom_select` and `tom_select_search` |

alchemy-devise removes these methods of `Alchemy::User`:

| Removed | Use instead |
| ------- | ----------- |
| `Alchemy::User.admins` | `Alchemy::User.alchemy_admins` |
| `Alchemy::User.human_rolename` | `Alchemy::User.human_alchemy_rolename` |
| `add_role` | `alchemy_roles=` |
| `is_admin?` | `alchemy_admin?` |
| `has_role?` | `has_alchemy_role?` |
| `human_roles_string` | `human_alchemy_roles` |
| `pages_locked_by_me` | `locked_pages` |
| `role`, `role_symbols` | `alchemy_roles` |
| `Alchemy::Devise.layout`, `Alchemy::Devise.devise_modules` | `Alchemy::Devise.config.layout`, `Alchemy::Devise.config.devise_modules` |

#### Deprecated Columns

Alchemy 9.0 does not drop any columns from existing databases. The page metadata columns, moved to page versions in 8.1, and the `public` column of elements, replaced by publication timestamps in 8.4, are ignored. The 9.0 upgrade task asks whether to remove them. You can also remove them later with:

~~~ bash
bin/rails alchemy:tidy:remove_deprecated_columns
~~~

#### New in 9.0

- A read-only **Definitions** module lists all page types with their elements, nested elements and ingredients, and how often each element is used. Page definitions accept a new `image` option in `page_layouts.yml` that it shows as a preview.
- The pages tree folds pages below the first level by default.

## Upgrading in Production

After deploying a new version of the `alchemy_cms` gem, database migrations run automatically via `db:prepare`.

The `alchemy:upgrade` task bundles several individual upgrade tasks. Some of these (like data migrations) need to run in production, while others (like config or file changes) are meant for development only. Check the output of `bin/rails -T alchemy:upgrade` and run the relevant tasks individually in production as needed.

## Verify the Upgrade

After upgrading:

1. Review the changes with `git diff`
2. Run your test suite
3. Check the [CHANGELOG](https://github.com/AlchemyCMS/alchemy_cms/blob/main/CHANGELOG.md) for details on what changed
