---
prev:
  text: Configuration
  link: configuration
next:
  text: Updating
  link: upgrading
---

# Deployment

Alchemy is a standard Rails application. It works on any platform that runs Rails: Heroku, Render.com, Fly.io, DigitalOcean App Platform, and others. If you can deploy a Rails app, you can deploy Alchemy. This guide covers the production concerns specific to running AlchemyCMS. The key concern on platforms with ephemeral filesystems is [remote storage](#remote-storage) for uploaded files.

For general Rails deployment guidance, see [Deploying to Production](https://guides.rubyonrails.org/getting_started.html#deploying-to-production) in the official Rails guides.

<ServiceAd href="https://blish.cloud/en/solutions/alchemycms">
<template #before>Don't want to manage your own infrastructure? Our sponsor</template>
<template #after>offers <a href="https://blish.cloud/en/solutions/alchemycms" target="_blank">managed Alchemy hosting</a>.</template>
</ServiceAd>

For a step-by-step example, see the [Deploy with Kamal](how_to_deploy_with_kamal) guide.

## Production Checklist

Before deploying, make sure you have:

- An image processing library installed (ImageMagick or libvips)
- Remote storage configured for pictures and attachments (on ephemeral filesystems)
- A database (PostgreSQL, MySQL, or SQLite)

## Image Processing

Alchemy requires an image processing library to be installed on your production server for cropping and resizing images.

- **ActiveStorage** supports both **libvips** (recommended, faster and lower memory) and **ImageMagick**
- **Dragonfly** only supports **ImageMagick**

Most deployment targets (Docker images, PaaS platforms) need you to explicitly install one of these. For example, in a Debian-based Dockerfile:

~~~dockerfile
# libvips (ActiveStorage only)
RUN apt-get install --no-install-recommends -y libvips

# or ImageMagick (required for Dragonfly, also works with ActiveStorage)
RUN apt-get install --no-install-recommends -y imagemagick
~~~

See the [Rendering Images](render_images) guide for details on configuring the image processor.

## Remote Storage

On platforms with ephemeral filesystems (Docker containers, Heroku, Fly.io, Render.com), you must configure remote storage for both **pictures** and **attachments**. Without it, uploaded files will be lost on every deploy.

**With ActiveStorage**, configure a remote service in `config/storage.yml`:

~~~yaml
amazon:
  service: S3
  bucket: your-bucket
  region: us-east-1
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
~~~

Then set it as the active service in `config/environments/production.rb`:

~~~ruby
config.active_storage.service = :amazon
~~~

**With Dragonfly**, use the [alchemy-dragonfly-s3](https://github.com/AlchemyCMS/alchemy-dragonfly-s3) gem.

See the [Rendering Images](render_images#remote-storage) guide for the full setup.

## Database

Alchemy uses standard Rails migrations. Use `db:prepare` for every deploy:

~~~bash
bin/rails db:prepare
~~~

This creates the database if it doesn't exist yet, and runs any pending migrations.

If you use Alchemy's page seeding feature, add the seeder to your `db/seeds.rb`:

~~~ruby
Alchemy::Seeder.seed!
~~~

:::tip NOTE
This is optional. Even without it, Alchemy bootstraps the default site, language, and root page on first sign-in.
:::

## Caching

Alchemy sets `Cache-Control` headers on published pages. This works with any CDN or reverse proxy (Cloudflare, CloudFront, Nginx, etc.) without additional configuration.

For efficient CDN caching, consider setting `stale_while_revalidate`:

~~~ruby
Alchemy.config.page_cache.stale_while_revalidate = 3600
~~~

:::tip INFO
This tells CDNs to serve stale content while fetching a fresh version in the background, reducing latency for visitors.
:::

See the [Configuration](configuration#caching) guide for more cache settings.

