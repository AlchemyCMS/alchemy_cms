# Alchemy I18n - Claude Code Guidelines

## Project Overview

This gem provides translations for [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms). Translation files live in `locales/alchemy.<locale>.yml`.

## Reference Codebase

The Alchemy CMS source is at `~/code/alchemy_cms`. Always use this local checkout to:
- Look up where translation keys are used
- Check the English reference locale at `config/locales/alchemy.en.yml`
- Verify keys are actually used before adding translations

## Rake Tasks

- `bundle exec rake translations:status` — Show translation coverage for all locales
- `bundle exec rake "translations:missing[de]"` — Show missing keys for a specific locale
- `bundle exec rake translations:validate` — Validate YAML syntax for all locale files

Set `ALCHEMY_CMS_PATH` env var if the Alchemy CMS checkout is not at `~/code/alchemy_cms`.

## Translation Workflow

1. Run `translations:missing[<locale>]` to find missing keys
2. Check the Alchemy CMS codebase to verify keys are actually used before translating
3. Only **add** missing keys — never remove existing keys without explicit permission
4. Keys with `nil` values in the EN locale (like `element_names`, `ingredient_roles`, `page_layout_names`) are user-customizable placeholders — do not add them to other locales
5. Some keys exist only in code (not in the EN locale file) and rely on `Alchemy.t`'s fallback (humanizing the key). These still need translations in other locales.
6. Validate YAML after editing: `bundle exec rake translations:validate`
7. Commit one language per commit

## How Alchemy.t Works

`Alchemy.t(key)` automatically scopes all lookups under the `alchemy` namespace. So `Alchemy.t(:hello)` looks up `alchemy.hello`, and `Alchemy.t(:name, scope: [:filters, :page])` looks up `alchemy.filters.page.name`. See `alchemy_cms/lib/alchemy/i18n.rb` for details.

## Translation Style

- Use consistent formatting within each locale file
- Preserve existing YAML anchors (e.g., `&mime_types` and `<<: *mime_types`)
- Keep keys in the same order as they appear in the file — add new keys near related existing keys
- When unsure about a translation, ask — do not guess
