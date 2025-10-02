Alchemy.configure do |config|
  # == This is the global Alchemy configuration file
  #

  # === Auto Log Out Time
  #
  # The amount of time of inactivity in minutes after which the user is kicked out of his current session.
  #
  # NOTE: This is only active in production environments
  #
  # config.auto_logout_time = 30

  # === Page caching
  #
  # Enable/Disable page caching globally.
  #
  # NOTE: You can enable/disable page caching for single Alchemy::Definitions in the page_layout.yml file.
  #
  # config.cache_pages = true

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
  #
  # config.sitemap.tap do |sitemap|
  #   sitemap.show_root = true
  #   sitemap.show_flag = false
  # end

  # === Default items per page in admin views
  #
  # In Alchemy's Admin, change how many items you would get shown per page by Kaminari
  # config.items_per_page = 15

  # === Preview window URL configuration
  #
  # By default Alchemy uses its internal page preview renderer,
  # but you can configure it to be any URL instead.
  #
  # Basic Auth is supported.
  #
  # config.preview = {
  #   host: https://www.my-static-site.com
  #   auth:
  #     username: <%= ENV["BASIC_AUTH_USERNAME"] %%>
  #     password: <%= ENV["BASIC_AUTH_PASSWORD"] %%>
  # }
  # Preview config per site is supported as well.
  #
  # config.preview = {
  #   My site name:
  #     host: https://www.my-static-site.com
  #     auth:
  #       username: <%= ENV["BASIC_AUTH_USERNAME"] %%>
  #       password: <%= ENV["BASIC_AUTH_PASSWORD"] %%>
  # }

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
  # config.output_image_quality = 85
  # config.preprocess_image_resize = nil
  # config.image_output_format = "original"

  # This is used by the seeder to create the default site.
  # config.default_site.tap do |default_site|
  #   default_site.name = "Default Site"
  #   default_site.host = "*"
  # end

  # This is the default language when seeding.
  config.default_language.tap do |default_language|
    default_language.code = "en"
    default_language.name = "English"
    # default_language.page_layout = "index"
    # default_language.frontpage_name = "Index"
  end

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
  # config.mailer.tap do |mailer|
  #   mailer.page_layout_name = "contact"
  #   mailer.forward_to_page = false
  #   mailer.mail_success_page = "thanks"
  #   mailer.mail_from = "your.mail@your-domain.com"
  #   mailer.mail_to = "your.mail@your-domain.com"
  #   mailer.subject = "A new contact form message"
  #   mailer.fields = ["salutation", "firstname", "lastname", "address", "zip", "city", "phone", "email", "message"]
  #   mailer.validate_fields = ["lastname", "email"]
  # end

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
  # config.user_roles = ["member", "author", "editor", "admin"]

  # === Uploader Settings
  #
  #   upload_limit       [Integer]    # Set an amount of files upload limit of files which can be uploaded at once. Set 0 for unlimited.
  #   file_size_limit*   [Integer]    # Set a file size limit in mega bytes for a per file limit.
  #
  # *) Allow filetypes to upload. Pass * to allow all kind of files.
  #
  # config.uploader.tap do |uploader|
  #   uploader.upload_limit = 50
  #   uploader.file_size_limit = 100
  #   uploader.allowed_filetypes.tap do |file_types|
  #     file_types.alchemy_attachments = ["*"]
  #     file_types.alchemy_pictures = ["jpg", "jpeg", "gif", "png", "svg", "webp"]
  #   end
  # end

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
  # config.link_target_options = ["blank"]

  # The layout used for rendering the +alchemy/admin/pages#show+ action.
  # config.admin_page_preview_layout = "application"

  # The sizes for the preview size select in the page editor.
  # config.page_preview_sizes = [360, 640, 768, 1024, 1280, 1440]

  # The storage adapter for Pictures and Attachments
  #
  config.storage_adapter = "dragonfly"
end
