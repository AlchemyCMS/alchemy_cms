module Alchemy
  module Tinymce
    mattr_accessor :languages, :plugins

    @@plugins = %w(alchemy_link anchor autoresize charmap code directionality fullscreen hr link paste tabfocus table)
    @@languages = %w(en de)
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
      @@init.merge!(settings)
    end

    def self.init
      @@init
    end

    def self.custom_config_contents(page = nil)
      if page
        content_definitions_from_elements(page.element_definitions)
      else
        content_definitions_from_elements(Element.definitions)
      end
    end

    private

    def self.content_definitions_from_elements(definitions)
      definitions.collect { |el|
        next if el['contents'].blank?
        contents = el['contents'].select { |c|
          c['settings'] && c['settings']['tinymce'].is_a?(Hash)
        }
        next if contents.blank?
        contents.map { |c| c.merge('element' => el['name']) }
      }.flatten.compact
    end
  end
end
