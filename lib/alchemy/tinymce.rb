module Alchemy
  module Tinymce
    mattr_accessor :languages, :plugins

    @@plugins = %w(alchemy_link autoresize charmap code directionality fullscreen link paste tabfocus table)
    @@languages = ['en', 'de']
    @@init = {
      content_css: '/assets/alchemy/tinymce_content.css',
      skin: 'alchemy',
      width: '100%',
      resize: false,
      autoresize_min_height: '105',
      menubar: false,
      statusbar: false,
      toolbar1: 'bold italic underline | strikethrough subscript superscript | numlist bullist indent outdent | removeformat | fullscreen',
      toolbar2: 'pastetext charmap code | undo redo | alchemy_link unlink',
      fix_list_elements: true,
      convert_urls: false,
      entity_encoding: 'raw'
    }

    def self.init=(settings)
      @@init.merge!(settings)
    end

    def self.init
      @@init
    end

    def self.custom_config_contents
      @@custom_config_contents ||= content_definitions_from_elements(Element.definitions)
    end

    private

    def self.content_definitions_from_elements(definitions)
      definitions.collect do |el|
        contents = el.fetch('contents', []).select { |c| c['settings'] && c['settings']['tinymce'].present? }
        next if contents.blank?
        contents.map { |c| c.merge('element' => el['name']) }
      end.flatten.compact
    end

  end
end
