module Alchemy
  module I18n

    # Alchemy translation methods
    #
    # Instead of having to translate strings and defining a default value:
    #
    #     Alchemy::I18n.t("Hello World!", :default => 'Hello World!')
    #
    # We define this method to define the value only once:
    #
    #     Alchemy::I18n.t("Hello World!")
    #
    # Note that interpolation still works:
    #
    #     Alchemy::I18n.t("Hello %{world}!", :world => @world)
    #
    # It offers a shortcut method and view helper called _t
    #
    # === Notes
    #
    # All translations are scoped into the +alchemy+ namespace.
    # Even scopes are scoped into the +alchemy+ namespace.
    #
    # So a call for _t('hello', :scope => :world) has to be translated like this:
    #
    #   de:
    #     alchemy:
    #       world:
    #         hello: Hallo
    #
    def self.t(msg, *args)
      options = args.extract_options!
      humanize_default_string!(msg, options)
      scope = ['alchemy']
      case options[:scope].class.name
      when "Array"
        scope += options[:scope]
      when "String"
        scope << options[:scope]
      when "Symbol"
        scope << options[:scope] unless options[:scope] == :alchemy
      end
      ::I18n.t(msg, options.merge(:scope => scope))
    end

    def self.available_locales
      @@available_locales ||= nil
      @@available_locales || translation_files.collect { |f| f.match(/.{2}\.yml$/).to_s.gsub(/\.yml/, '').to_sym }
    end

    def self.available_locales=(locales)
      @@available_locales = Array(locales).map { |locale| locale.to_sym }
      @@available_locales = nil if @@available_locales.empty?
    end

    def self.translation_files
      Dir.glob(File.join(File.dirname(__FILE__), '../../config/locales/alchemy.*.yml'))
    end

  private

    def self.humanize_default_string!(msg, options)
      if options[:default].blank?
        options[:default] = msg.is_a?(Symbol) ? msg.to_s.humanize : msg
      end
    end

  end
end
