---
prev:
  text: Menus
  link: menus
next:
  text: Configuration
  link: configuration
---

# Rendering Images

Images are stored as originals in the Alchemy picture library. Editors assign these images to [Picture ingredients](ingredients#picture) on elements. You control the rendering dimensions, cropping, and output format through ingredient settings and rendering options.

Alchemy supports two storage adapters: **ActiveStorage** and **Dragonfly**. Both use the same rendering API, so you can switch between them without changing your templates.

## Configuration

Image rendering is configured through `Alchemy.config`. See the [Configuration guide](configuration) for general setup.

~~~ ruby
# config/initializers/alchemy.rb
Alchemy.config.output_image_quality = 85
Alchemy.config.preprocess_image_resize = "1000x1000"
Alchemy.config.image_output_format = "original"
Alchemy.config.sharpen_images = false
~~~

::: tip
You can override the output format and quality per ingredient by passing `format` and `quality` in the ingredient settings or as rendering options.
:::

## Rendering

In most cases, rendering a Picture ingredient through `el.render(:image)` in your element view is all you need. It generates the correct image URL with all configured options applied.

~~~ erb
<%# app/views/alchemy/elements/_article.html.erb %>
<%= el.render(:hero_image) %>
~~~

The Picture ingredient view component handles resizing, cropping, srcset generation, and link wrapping automatically based on your ingredient settings.

### Ingredient Settings

Configure rendering in your `elements.yml` definition.

~~~ yaml
- name: article
  ingredients:
    - role: hero_image
      type: Picture
      settings:
        size: 1200x600
        crop: true
~~~

See the [Picture ingredient settings](ingredients#picture) for the full list of options.

### Rendering Options

These options control how the image variant is generated.

#### size
`String`

The dimensions to resize the image to, preserving aspect ratio. Example: `"400x300"`.

#### crop
`Boolean`

Crop the image to exactly match the given size.

#### format
`String`

The output format: `"jpg"`, `"png"`, `"gif"`, or `"webp"`.

#### quality
`Integer`

The quality of rendered JPEG and WebP images.

#### upsample
`Boolean`

Allow the image to be scaled up beyond its original dimensions. By default, images are only scaled down.

## Responsive Images

Use the `srcset` and `sizes` ingredient settings to generate responsive `<img>` tags with multiple sources.

~~~ yaml
- role: photo
  type: Picture
  settings:
    size: 1200x800
    crop: true
    srcset: ['400x267', '800x533', '1200x800']
    sizes: ['(max-width: 600px) 400px', '(max-width: 900px) 800px', '1200px']
~~~

This renders an `<img>` tag with a `srcset` attribute containing URLs for each size and a `sizes` attribute telling the browser which source to use at each viewport width.

## Remote Storage

In production you typically want to store images on a remote service like Amazon S3, Google Cloud Storage, or Azure Storage instead of the local filesystem.

**With ActiveStorage**, configure your storage service in `config/storage.yml` and set the active service in your environment config, just like any Rails application. See the [Active Storage Overview](https://guides.rubyonrails.org/active_storage_overview.html#setup) in the Rails guides.

~~~ yaml
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: eu-central-1
  bucket: my-app-production
~~~

~~~ ruby
# config/environments/production.rb
config.active_storage.service = :amazon
~~~

**With Dragonfly**, use the [alchemy-dragonfly-s3](https://github.com/AlchemyCMS/alchemy-dragonfly-s3) extension to store images on S3 compatible services.

## Caching

Alchemy caches rendered image variants automatically. The caching strategy depends on your storage adapter.

**ActiveStorage** uses Rails' built-in variant caching. Variants are generated on first request and stored alongside the original blob.

**Dragonfly** uses Alchemy's `PictureThumb` model to cache rendered variants in the database. Three admin thumbnail sizes are pregenerated on upload.

In both cases, adding a CDN in front of your application is recommended for production to avoid hitting the application server for repeated image requests.
