---
prev: false
next: false
---

# Languages

Alchemy has built-in multi-language support. Each [site](sites) can have multiple languages, each with its own page tree, menus, and content.

## How Languages Work

Every language belongs to a site and is defined by a language code (e.g. `en`, `de`) and an optional country code (e.g. `US`, `AT`). One language per site must be marked as the default.

| Attribute | Description |
|-----------|-------------|
| **Name** | Display name (e.g. "English", "Deutsch") |
| **Language code** | ISO 639-1 code (e.g. `en`, `de`, `fr`) |
| **Country code** | ISO 3166 code (e.g. `US`, `AT`, `CH`) |
| **Public** | Whether the language is visible to visitors |
| **Default** | The fallback language for the site (always public) |
| **Frontpage name** | Name of the root page for this language |
| **Page layout** | Default page layout for the root page |

## Creating a New Language

Add languages through the admin interface under the Languages module. When you create a new language, Alchemy creates a root page for it using the configured page layout.

## Switching Languages in the Admin

Editors switch between languages using the language selector in the admin interface. Each language has its own page tree and menu structure that editors manage independently.

## Single-Language Setups

The installer creates a default language during setup. If your site only needs one language, no additional configuration is required.
