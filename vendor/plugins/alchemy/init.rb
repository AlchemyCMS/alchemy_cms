require 'extensions/hash'
require 'extensions/form_helper'
require 'alchemy/controller'
require 'injections/attachment_fu_mime_type'

if defined?(Ddb::Userstamp)
  Ddb::Userstamp.compatibility_mode = true
end

ActionController::Base.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

if defined?(FastGettext)
  FastGettext.add_text_domain 'alchemy', :path => File.join(RAILS_ROOT, 'vendor/plugins/alchemy/locale')
  FastGettext.text_domain = 'alchemy'
end

ActionController::Base.session = {
  :key => '_alchemy_session',
  :secret => 'ef0af4870c35c7c9ca584e5b5382ac187c5731b839f663ad4cee2e72625c1bd006d7b934265d43d34b102ed10a657f0aa5b9512b4ae328314f3416e30b0746cd'
}

ActionController::Dispatcher.middleware.insert_before(
  ActionController::Base.session_store,
  FlashSessionCookieMiddleware,
  ActionController::Base.session_options[:key]
)

Tinymce::Hammer.install_path = '/plugin_assets/alchemy/javascripts/tiny_mce'
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
  [:popup_css, "/plugin_assets/alchemy/stylesheets/alchemy_tinymce_dialog.css"],
  [:content_css, "/plugin_assets/alchemy/stylesheets/alchemy_tinymce_content.css"],
  [:dialog_type, "modal"],
  [:width, "378"],
  [:height, '185'],
  [:theme_advanced_toolbar_align, 'left'],
  [:theme_advanced_toolbar_location, 'top'],
  [:theme_advanced_statusbar_location, 'bottom'],
  [:theme_advanced_buttons1, 'bold,italic,underline,strikethrough,sub,sup,|,numlist,bullist,indent,outdent,|,wa_link,wa_unlink,|,removeformat,cleanup,|,fullscreen'],
  [:theme_advanced_buttons2, 'pastetext,pasteword,charmap,code'],
  [:theme_advanced_buttons3, ''],
  [:theme_advanced_resizing, 'true'],
  [:theme_advanced_resize_horizontal, false],
  [:theme_advanced_resizing_min_height, '185'],
  [:fix_list_elements, true],
  [:convert_urls, false]
]
