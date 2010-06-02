require 'gettext/utils'
begin
  require 'gettext/tools/rgettext'
rescue LoadError #version prior to 2.0
  require 'gettext/rgettext'
end

module GettextI18nRails
  module HamlParser
    module_function

    def target?(file)
      File.extname(file) == '.haml'
    end

    def parse(file, msgids = [])
      return msgids unless load_haml
      require 'gettext_i18n_rails/ruby_gettext_extractor'

      text = IO.readlines(file).join

      haml = Haml::Engine.new(text)
      code = haml.precompiled
      return RubyGettextExtractor.parse_string(code, file, msgids)
    end

    def load_haml
      return true if @haml_loaded
      begin
        require "#{RAILS_ROOT}/vendor/plugins/haml/lib/haml"
      rescue LoadError
        begin
          require 'haml'  # From gem
        rescue LoadError
          puts "A haml file was found, but haml library could not be found, so nothing will be parsed..."
          return false
        end
      end
      @haml_loaded = true
    end
  end
end
GetText::RGetText.add_parser(GettextI18nRails::HamlParser)