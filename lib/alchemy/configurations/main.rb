# frozen_string_literal: true

require "alchemy/configuration"
require "alchemy/configurations/default_language"
require "alchemy/configurations/default_site"
require "alchemy/configurations/format_matchers"
require "alchemy/configurations/mailer"
require "alchemy/configurations/page_cache"
require "alchemy/configurations/preview"
require "alchemy/configurations/sitemap"
require "alchemy/configurations/uploader"
require "alchemy/deprecation"

module Alchemy
  module Configurations
    class Main < Alchemy::Configuration
      # == This is the global Alchemy configuration class

      # === Auto Log Out Time
      #
      # The amount of time of inactivity in minutes after which the user is kicked out of his current session.
      #
      # NOTE: This is only active in production environments
      #
      option :auto_logout_time, :integer, default: 30

      # === Page caching
      #
      # Enable/Disable page caching globally.
      #
      # NOTE: You can enable/disable page caching for single Alchemy::Definitions in the page_layout.yml file.
      #
      option :cache_pages, :boolean, default: true

      # === Page caching max age
      #
      # max-age [Integer] # The duration in seconds for which the page is cached before revalidation.
      # stale-while-revalidate [Boolean] # If true, enables the stale-while-revalidate caching strategy.
      configuration :page_cache, PageCache

      # === Sitemap
      #
      # Alchemy creates a XML, Google compatible, sitemap for you.
      #
      # The url is: http://your-domain.tld/sitemap.xml
      #
      # ==== Config Options:
      #
      #   show_root [Boolean] # Show language root page in sitemap?
      #   show_flag [Boolean] # Enables the Checkbox in Page#update overlay. So your customer can set the visibility of pages in the sitemap.
      configuration :sitemap, Sitemap

      # === Default items per page in admin views
      #
      # In Alchemy's Admin, change how many items you would get shown per page by Kaminari
      option :items_per_page, :integer, default: 15

      # === Preview window URL configuration
      #
      # By default Alchemy uses its internal page preview renderer,
      # but you can configure it to be any URL instead.
      #
      # Basic Auth is supported.
      #
      # preview:
      #   host: https://www.my-static-site.com
      #   auth:
      #     username: <%= ENV["BASIC_AUTH_USERNAME"] %>
      #     password: <%= ENV["BASIC_AUTH_PASSWORD"] %>
      #
      # Preview config per site is supported as well.
      #
      # preview:
      #   My site name:
      #     host: https://www.my-static-site.com
      #     auth:
      #       username: <%= ENV["BASIC_AUTH_USERNAME"] %>
      #       password: <%= ENV["BASIC_AUTH_PASSWORD"] %>
      #
      configuration :preview, Preview

      # === Picture rendering settings
      #
      # Alchemy uses Dragonfly to render images. Settings for image rendering are specific to elements and are defined in elements.yml
      #
      # Example:
      # - name: some_element
      #   ingredients:
      #   - role: some_picture
      #     type: Picture
      #     settings:
      #       hint: true
      #       crop: true  # turns on image cropping
      #       size: '500x500' # image will be cropped to this size
      #
      # See http://markevans.github.com/dragonfly for further info.
      #
      # ==== Global Options:
      #
      #   output_image_quality      [Integer]       # If image gets rendered as JPG or WebP this is the quality setting for it. (Default 85)
      #   preprocess_image_resize   [String]        # Use this option to resize images to the given size when they are uploaded to the image library. Downsizing example: '1000x1000>' (Default nil)
      #   image_output_format       [String]        # The global image output format setting. (Default +original+)
      #
      # NOTE: You can always override the output format in the settings of your ingredients in elements.yml, I.E. {format: 'gif'}
      #
      option :output_image_quality, :integer, default: 85
      alias_method :output_image_jpg_quality, :output_image_quality
      deprecate output_image_jpg_quality: :output_image_quality, deprecator: Alchemy::Deprecation
      alias_method :output_image_jpg_quality=, :output_image_quality=
      deprecate "output_image_jpg_quality=": :output_image_quality=, deprecator: Alchemy::Deprecation
      option :preprocess_image_resize, :string
      option :image_output_format, :string, default: "original"
      option :sharpen_images, :boolean, default: false

      # This is used by the seeder to create the default site.
      configuration :default_site, DefaultSite

      # This is the default language when seeding.
      configuration :default_language, DefaultLanguage

      # === Mailer Settings:
      #
      # To send emails via contact forms, you can create your form fields here and set which fields are to be validated.
      #
      # === Validating fields:
      #
      # Pass the field name as a symbol and a message_id (will be translated) to :validate_fields:
      #
      # ==== Options:
      #
      #   page_layout_name:           [String] # A +Alchemy::PageDefinition+ name. Used to render the contactform on a page with this layout.
      #   fields:                     [Array]  # An Array of fieldnames.
      #   validate_fields:            [Array]  # An Array of fieldnames to be validated on presence.
      #
      # ==== Translating validation messages:
      #
      # The validation messages are passed through ::I18n.t so you can translate it in your language yml file.
      #
      # ==== Example:
      #
      #   de:
      #     activemodel:
      #       attributes:
      #         alchemy/message:
      #           firstname: Vorname
      #
      configuration :mailer, Mailer

      # === User roles
      #
      # You can add own user roles.
      #
      # Further documentation for the auth system used please visit:
      #
      # https://github.com/ryanb/cancan/wiki
      #
      # ==== Translating User roles
      #
      # Userroles can be translated inside your the language yml file under:
      #
      #   alchemy:
      #     user_roles:
      #       rolename: Name of the role
      #
      option :user_roles, :string_list, default: %w[member author editor admin]

      # === Uploader Settings
      #
      #   upload_limit       [Integer]    # Set an amount of files upload limit of files which can be uploaded at once. Set 0 for unlimited.
      #   file_size_limit*   [Integer]    # Set a file size limit in mega bytes for a per file limit.
      #
      # *) Allow filetypes to upload. Pass * to allow all kind of files.
      #
      configuration :uploader, Uploader

      # === Link Target Options
      #
      # Values for the link target selectbox inside the page link overlay.
      # The value gets attached as a data-link-target attribute to the link.
      #
      # == Example:
      #
      # Open all links set to overlay inside an jQuery UI Dialog Window.
      #
      #   jQuery(a[data-link-target="overlay"]).dialog();
      #
      option :link_target_options, :string_list, default: %w[blank]

      # === Format matchers
      #
      # Named aliases for regular expressions that can be used in various places.
      # The most common use case is the format validation of ingredients, or attribute validations of your individual models.
      #
      # == Example:
      #
      #   validates_format_of :url, with: Alchemy.config.format_matchers.url
      #
      configuration :format_matchers, FormatMatchers

      # The layout used for rendering the +alchemy/admin/pages#show+ action.
      option :admin_page_preview_layout, :string, default: "application"

      # The sizes for the preview size select in the page editor.
      option :page_preview_sizes, :integer_list, default: [360, 640, 768, 1024, 1280, 1440]

      # Enable full text search configuration
      #
      # It enables a searchable checkbox in the page form to toggle
      # the searchable field. These information can used in a search
      # plugin (e.g. https://github.com/AlchemyCMS/alchemy-pg_search).
      #
      # == Example
      #
      #     # config/initializers/alchemy.rb
      #     Alchemy.config.page_searchable_checkbox = true
      option :show_page_searchable_checkbox, :boolean, default: false

      # The storage adapter for Pictures and Attachments
      #
      option :storage_adapter, :string, default: "dragonfly"
    end
  end
end
