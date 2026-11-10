---
prev: false
next: false
---

# Seeder

The seeder creates pages, layout pages, and users from YAML files. Use it to set up a consistent page structure across environments or to bootstrap a fresh database.

## Setup

The installer adds `Alchemy::Seeder.seed!` to your `db/seeds.rb` automatically. If you skipped the installer or need to add it manually:

~~~ ruby
# db/seeds.rb
Alchemy::Seeder.seed!
~~~

Then run:

~~~ bash
bin/rails db:seed
~~~

## Seeding Pages

Create a `db/seeds/alchemy/pages.yml` file with your page hierarchy. The file must contain exactly one root content page. Nest children under the `children` key:

~~~ yaml
# db/seeds/alchemy/pages.yml
- name: Homepage
  page_layout: index
  children:
    - name: About Us
      page_layout: standard
    - name: Blog
      page_layout: blog
      children:
        - name: First Post
          page_layout: blogpost
          public_on: 2025-01-15
    - name: Contact
      page_layout: contact
~~~

Each entry accepts any `Alchemy::Page` attribute. The most common ones:

| Attribute | Description |
|-----------|-------------|
| `name` | Page name shown in the admin |
| `page_layout` | Must match a layout defined in `page_layouts.yml` |
| `public_on` | Publish date (`Date` or `DateTime`). Omit for unpublished drafts |
| `children` | Nested array of child pages |

### Layout Pages

Layout pages (headers, footers, sidebars) are global pages not part of the content tree. Mark them with `layoutpage: true`:

~~~ yaml
- name: Homepage
  page_layout: index
  children:
    - name: About Us
      page_layout: standard

- name: Footer
  layoutpage: true
  page_layout: footer

- name: Header
  layoutpage: true
  page_layout: header
~~~

## Seeding Users

Create a `db/seeds/alchemy/users.yml` file. Each entry is passed directly to your user model's `create!` method, so the attributes depend on your user model:

~~~ yaml
# db/seeds/alchemy/users.yml
- email: admin@example.com
  password: secret123
  alchemy_roles:
    - admin

- email: editor@example.com
  password: secret123
  alchemy_roles:
    - editor
~~~

::: warning
User seeds are meant for development and staging environments. Do not commit real credentials.
:::

## Idempotent Behavior

The seeder checks for existing data before creating records:

- **Pages** — skips if any pages exist in the database
- **Users** — skips if any users exist in the database

To reseed, reset the database first:

~~~ bash
bin/rails db:reset
~~~

## Default Site and Language

If no site or language exists when seeding pages, the seeder creates them from your [configuration](configuration#default-site-and-language). Make sure your initializer has these configured before seeding.
