---
prev:
  text: Rendering Images
  link: render_images
next:
  text: Deployment
  link: deployment
---

# Configuration

Alchemy is configured through a Ruby initializer at `config/initializers/alchemy.rb`. The install generator creates this file for you. All settings have sensible defaults — you only need to configure what you want to change.

### The Initializer

~~~ ruby
# config/initializers/alchemy.rb
Alchemy.configure do |config|
  config.output_image_quality = 85
  config.storage_adapter = "active_storage"
end
~~~

::: info NOTE
`Alchemy.configure` is available since 8.1. In 8.0, use `Alchemy.config.tap` instead.
:::

### Environment-Specific Configuration

Use Rails' standard environment files to override settings per environment.

~~~ ruby
# config/environments/production.rb
Rails.application.configure do
  Alchemy.config.cache_pages = true
end
~~~

## Default Site and Language

Used by the built-in onboarding to create the initial site, language, and frontpage.

~~~ ruby
config.default_site.tap do |default_site|
  default_site.name = "Default Site"
  default_site.host = "*"
end

config.default_language.tap do |default_language|
  default_language.name = "English"
  default_language.code = "en"
  default_language.page_layout = "index"
  default_language.frontpage_name = "Index"
end
~~~

## Images

See the [Rendering Images guide](render_images) for details on these settings.

### output_image_quality
`Integer` (Default: `85`)

Quality for rendered JPEG and WebP images.

### preprocess_image_resize
`String` (Default: `nil`)

Downsize images on upload. Example: `"1000x1000"`.

### image_output_format
`String` (Default: `"original"`)

Global output format. `"original"`, `"jpg"`, `"png"`, or `"webp"`.

### sharpen_images
`Boolean` (Default: `false`)

Enable image sharpening on rendered variants.

### storage_adapter
`String`

The storage backend for pictures and attachments. Either `"active_storage"` or `"dragonfly"` (the default). Can also be set via the `ALCHEMY_STORAGE_ADAPTER` environment variable.

## Caching

### cache_pages
`Boolean` (Default: `true`)

Enable or disable page caching globally. You can also [control caching per page layout](pages#caching).

### page_cache

Controls the `Cache-Control` headers for cached pages.

~~~ ruby
config.page_cache.tap do |page_cache|
  page_cache.max_age = 600                  # max-age in seconds (default: 600)
  page_cache.stale_while_revalidate = 3600  # stale-while-revalidate in seconds (default: nil)
end
~~~

:::tip NOTE
When `stale_while_revalidate` is not set, Alchemy sends `must-revalidate` in the `Cache-Control` header instead.
:::

## Uploads

Configure upload limits and allowed file types.

~~~ ruby
config.uploader.tap do |uploader|
  uploader.upload_limit = 50
  uploader.file_size_limit = 100
  uploader.allowed_filetypes.tap do |file_types|
    file_types.alchemy_attachments = ["pdf", "zip"]  # default: ["*"] (all types)
    file_types.alchemy_pictures = ["jpg", "jpeg", "gif", "png", "svg", "webp"]  # default
  end
end
~~~

## Links

### link_target_options
`Array<String>` (Default: `["blank"]`)

Values for the link target select in the link dialog. The value is added as a `data-link-target` attribute.

### link_dialog_tabs

Extend the link dialog with custom tabs. The default tabs are: Internal, Anchor, External, and File.

~~~ ruby
config.link_dialog_tabs << "Acme::LinkTab"
~~~

::: tip
[alchemy-solidus](extensions#alchemy-solidus) provides a tab for linking to Solidus products.
:::

## Mailer

Configure Alchemy's built-in contact form mailer. See the [contact form guide](how_to_create_a_contact_form) for a full walkthrough.

~~~ ruby
config.mailer.tap do |mailer|
  mailer.page_layout_name = "contact"
  mailer.forward_to_page = false
  mailer.mail_success_page = "thanks"
  mailer.mail_from = "contact@example.com"
  mailer.mail_to = "admin@example.com"
  mailer.subject = "New contact form message"
  mailer.fields = ["name", "email", "message"]
  mailer.validate_fields = ["name", "email"]
end
~~~

## Sitemap

Alchemy generates a Google-compatible XML sitemap at `/sitemap.xml`.

~~~ ruby
config.sitemap.tap do |sitemap|
  sitemap.show_root = true
  sitemap.show_flag = false
end
~~~

Set `show_flag` to `true` to add a "Show in sitemap" checkbox to the page settings, allowing editors to control sitemap visibility per page.

## Publishing

### publish_targets

Trigger jobs when pages are published. For example, to notify a CDN or rebuild a static cache. Each target must be an `ActiveJob` class that accepts a page as argument.

~~~ ruby
config.publish_targets << PublishToCdnJob
~~~

## Admin UI

### admin_page_preview_layout
`String` (Default: `"application"`)

The layout used for rendering the page preview in the admin.

### page_preview_sizes
`Array<Integer>` (Default: `[360, 640, 768, 1024, 1280, 1440]`)

The viewport sizes available in the preview size selector.

### show_page_searchable_checkbox
`Boolean` (Default: `false`)

Show a searchable checkbox in the page form. Useful with search plugins like [alchemy-pg_search](extensions#alchemy-pg_search).

### auto_logout_time
`Integer` (Default: `30`)

Minutes of inactivity before the admin session expires. Used by [alchemy-devise](extensions#alchemy-devise) to configure Devise's `:timeoutable` module. Disabled in development.

### items_per_page
`Integer` (Default: `15`)

Number of items per page in admin list views (uses Kaminari).

## Admin JavaScript and CSS

Alchemy uses [importmap-rails](https://github.com/rails/importmap-rails) for JavaScript modules in the admin. You can extend the admin interface with custom modules and stylesheets.

~~~ ruby
# Pin a JS module and import it in the admin
Alchemy.importmap.pin "flatpickr/de",
  to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/l10n/de.js"
config.admin_js_imports << "flatpickr/de"

# Add a custom stylesheet
config.admin_stylesheets.add("my_app/admin_extension")
~~~

## Admin Path

Change the admin URL path or restrict access:

~~~ ruby
# config/initializers/alchemy.rb
Alchemy.admin_path = "backend"
Alchemy.admin_constraints = { subdomain: "admin" }
~~~

The default admin path is `/admin`.

## User Roles

### user_roles
`Array<String>` (Default: `["member", "author", "editor", "admin"]`)

Available user roles. Each role inherits the permissions of the previous one. See the [custom authentication guide](how_to_add_custom_authentication) for setting up your user model.

- **member** - Can view published pages and attachments, including restricted ones
- **author** - Can edit page content, manage elements and ingredients, browse the library
- **editor** - Can create, delete, publish and reorder pages, manage pictures, attachments and tags
- **admin** - Can manage languages, sites and system settings

You can also restrict which roles can edit specific page layouts with [`editable_by`](pages#editable_by). Alchemy uses [CanCanCan](https://github.com/CanCanCommunity/cancancan) for authorization. You can register custom abilities.

~~~ ruby
config.abilities << "MyCustom::Ability"
~~~

Roles can be translated in your locale files. See the [I18n guide](i18n) for details.

~~~ yaml
# config/locales/en.yml
en:
  alchemy:
    user_roles:
      member: Member
      author: Author
~~~

## Preview

Alchemy offers two ways to customize the admin's page preview.

### Preview Sources

When multiple preview sources are configured, a select menu appears in the admin preview frame. This is useful when you want to preview content across different frontends, for example if you use Alchemy as a headless CMS via [alchemy-json_api](extensions#alchemy-json_api):

~~~ ruby
config.preview_sources << "MyCustom::PreviewSource"
~~~

### Preview Host

To replace Alchemy's built-in server-side rendered preview entirely, configure a static preview host. This points the preview frame to an external URL, optionally with Basic Auth:

~~~ ruby
config.preview.tap do |preview|
  preview.host = "https://www.my-static-site.com"
  preview.auth.tap do |auth|
    auth.username = ENV["BASIC_AUTH_USERNAME"]
    auth.password = ENV["BASIC_AUTH_PASSWORD"]
  end
end
~~~

## Page URL Paths

Customize how page URLs are generated:

~~~ ruby
# config/initializers/alchemy.rb
Alchemy::Page.url_path_class = MyCustomUrlPath
~~~

The default `Alchemy::Page::UrlPath` builds URLs from the page's `urlname` and its ancestors. Your class must respond to `call` and return a path string.

## Format Matchers

Named aliases for regular expressions, commonly used for [ingredient validations](elements#validations).

~~~ ruby
# Use in your models
validates_format_of :url, with: Alchemy.config.format_matchers.url
~~~

## Error Tracking

Replace Alchemy's default error logger with your own handler:

~~~ ruby
# config/initializers/alchemy.rb
Alchemy::ErrorTracking.notification_handler = MyErrorHandler
~~~

Your class must respond to `call` with an exception argument.

::: tip
Ready-made integrations exist for the most common services: [Sentry](extensions#alchemy-sentry), [Bugsnag](extensions#alchemy-bugsnag), [AppSignal](extensions#alchemy-appsignal), and [Airbrake](https://github.com/AlchemyCMS/alchemy-airbrake). See [Extensions](extensions) for more.
:::

## Update Check

### update_check_service
`Symbol` (Default: `:alchemy_app`)

The service used to check for new Alchemy versions in the admin dashboard. Available options:

- `:alchemy_app` — Alchemy's own update check endpoint. Shares minimal data about your installation (Alchemy version, Rails version, Ruby version, origin host) with maintainers of AlchemyCMS
- `:ruby_gems` — RubyGems.org API. Recommended if you don't want to share any data with AlchemyCMS maintainers
- `:none` — Disables update checks

### update_check_cache_duration
`Integer` (Default: `1`)

How long (in hours) the update check result is cached.
