require 'extensions/hash'
require 'extensions/array'
require 'alchemy'
require 'injections/attachment_fu_mime_type'

if defined?(Authorization)
  Authorization::AUTH_DSL_FILES = Dir.glob("#{RAILS_ROOT}/vendor/plugins/*/config/authorization_rules.rb")
end

ActionController::Base.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

if defined?(FastGettext)
  FastGettext.add_text_domain 'alchemy', :path => File.join(RAILS_ROOT, 'vendor/plugins/alchemy/locale')
end

config.after_initialize do
  ActionController::Dispatcher.middleware.insert_before(
    ActionController::Base.session_store,
    FlashSessionCookieMiddleware,
    ActionController::Base.session_options[:key]
  )
end

Tinymce::Hammer.install_path = '/javascripts/alchemy/tiny_mce'
Tinymce::Hammer.plugins = %w(safari paste fullscreen inlinepopups alchemy_link)
Tinymce::Hammer.languages = ['de', 'en']
Tinymce::Hammer.init = [
  [:paste_convert_headers_to_strong, true],
  [:paste_convert_middot_lists, true],
  [:paste_remove_spans, true],
  [:paste_remove_styles, true],
  [:paste_strip_class_attributes, true],
  [:theme, 'advanced'],
  [:skin, 'o2k7'],
  [:skin_variant, 'silver'],
  [:inlinepopups_skin, 'alchemy'],
  [:popup_css, "/stylesheets/alchemy/alchemy_tinymce_dialog.css"],
  [:content_css, "/stylesheets/alchemy/alchemy_tinymce_content.css"],
  [:dialog_type, "modal"],
  [:width, "100%"],
  [:height, '185'],
  [:theme_advanced_toolbar_align, 'left'],
  [:theme_advanced_toolbar_location, 'top'],
  [:theme_advanced_statusbar_location, 'bottom'],
  [:theme_advanced_buttons1, 'bold,italic,underline,strikethrough,sub,sup,|,numlist,bullist,indent,outdent,|,alchemy_link,unlink,|,removeformat,cleanup,|,fullscreen'],
  [:theme_advanced_buttons2, 'pastetext,pasteword,charmap,code,help'],
  [:theme_advanced_buttons3, ''],
  [:theme_advanced_resizing, 'true'],
  [:theme_advanced_resize_horizontal, false],
  [:theme_advanced_resizing_min_height, '185'],
  [:fix_list_elements, true],
  [:convert_urls, false]
]
