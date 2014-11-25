module Alchemy
  module Tinymce
    mattr_accessor :languages, :plugins

    @@plugins = %w(alchemy_link anchor autoresize charmap code directionality fullscreen hr link paste tabfocus table)
    @@languages = ['en', 'de']
    @@init = {
      skin: 'alchemy',
      width: '100%',
      resize: true,
      autoresize_min_height: '105',
      autoresize_max_height: '480',
      menubar: false,
      statusbar: true,
      toolbar: [
        'bold italic underline | strikethrough subscript superscript | numlist bullist indent outdent | removeformat | fullscreen',
        'pastetext charmap hr | undo redo | alchemy_link unlink anchor | code'
      ],
      fix_list_elements: true,
      convert_urls: false,
      entity_encoding: 'raw',
      paste_as_text: true,
      element_format: 'html'
    }

    def self.init=(settings)
      if contains_old_tinymce_toolbar_config?('tinymce' => settings.stringify_keys)
        warn_about_deprecation!
      end
      @@init.merge!(settings)
    end

    def self.init
      @@init
    end

    def self.custom_config_contents(page = nil)
      if page
        definitions = content_definitions_from_elements(page.element_definitions)
      else
        definitions = content_definitions_from_elements(Element.definitions)
      end
      if definitions.any? { |d| contains_old_tinymce_toolbar_config?(d['settings']) }
        warn_about_deprecation!
      end
      definitions
    end

    private

    def self.content_definitions_from_elements(definitions)
      definitions.collect do |el|
        next if el['contents'].blank?
        contents = el['contents'].select { |c| c['settings'] && c['settings']['tinymce'].present? }
        next if contents.blank?
        contents.map { |c| c.merge('element' => el['name']) }
      end.flatten.compact
    end

    def self.contains_old_tinymce_toolbar_config?(settings)
      settings['tinymce'] && settings['tinymce'].keys.any? { |k| k.match(/toolbar[0-9]/) }
    end

    def self.warn_about_deprecation!
      ActiveSupport::Deprecation.warn("You use old TinyMCE 4.0 based toolbar config! Please consider to upgrade it to 4.1 compatible syntax. I.e. don't use 'toolbarN', use 'toolbar' with array instead. Visit http://www.tinymce.com/wiki.php/Configuration:toolbar for more information.")
    end
  end
end
