module Alchemy
  module Tinymce

    mattr_accessor :languages, :themes, :plugins, :setup

    @@setup = nil

    @@plugins = %w(alchemy_link autoresize fullscreen inlinepopups paste table)

    @@languages = ['en', 'de']

    @@themes = ['advanced']

    @@init = {
      :paste_convert_headers_to_strong => true,
      :paste_convert_middot_lists => true,
      :paste_remove_spans => true,
      :paste_remove_styles => true,
      :paste_strip_class_attributes => true,
      :theme => 'advanced',
      :skin => 'o2k7',
      :skin_variant => 'silver',
      :inlinepopups_skin => 'alchemy',
      :popup_css => "/assets/alchemy/tinymce_dialog.css",
      :content_css => "/assets/alchemy/tinymce_content.css",
      :dialog_type => "modal",
      :width => "100%",
      :theme_advanced_resizing => true,
      :theme_advanced_resize_horizontal => false,
      :theme_advanced_resizing_min_height => '135',
      :theme_advanced_toolbar_align => 'left',
      :theme_advanced_toolbar_location => 'top',
      :theme_advanced_statusbar_location => 'bottom',
      :theme_advanced_buttons1 => 'bold,italic,underline,strikethrough,sub,sup,|,numlist,bullist,indent,outdent,|,alchemy_link,unlink,|,removeformat,cleanup,|,fullscreen',
      :theme_advanced_buttons2 => 'pastetext,pasteword,charmap,code,help',
      :theme_advanced_buttons3 => '',
      :fix_list_elements => true,
      :convert_urls => false,
      :entity_encoding => "raw"
    }

    def self.init=(settings)
      @@init = @@init.merge(settings)
    end

    def self.init
      @@init
    end

    def self.custom_config_contents
      @@custom_config_contents ||= Content.descriptions.select { |c| c['settings'] && !c['settings']['tinymce'].nil? }
    end

  end
end
