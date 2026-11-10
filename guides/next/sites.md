---
prev: false
next: false
---

# Sites

Alchemy supports multiple websites from a single Rails application. Each site has its own domain, languages, and page trees.

## How Sites Work

A site is identified by its host name. When a request comes in, Alchemy matches it against the configured hosts and serves the correct site's content.

| Attribute | Description |
|-----------|-------------|
| **Name** | Display name of the site |
| **Host** | Primary domain (e.g. `www.example.com`) |
| **Aliases** | Additional domains that serve the same site (space-separated) |
| **Redirect to primary host** | When enabled, alias requests are redirected to the primary host |

## Setting Up Multiple Sites

The Alchemy installer creates a default site. To add more sites, use the admin interface under the Sites module.

Each site needs at least one [language](languages). After creating a new site, Alchemy will prompt you to create its default language.

## Single-Site Setups

Most Alchemy installations use a single site. In this case, you can ignore the Sites module entirely — the default site created during installation handles everything.
