module Alchemy
  class << self
    # Alchemy shortcut translation method
    #
    # Instead of having to call:
    #
    #     Alchemy::I18n.translate(:hello)
    #
    # You can use this shortcut method:
    #
    #     Alchemy.t(:hello)
    #
    def t(msg, *args)
      Alchemy::I18n.translate(msg, *args)
    end
  end

  module I18n
    class << self
      def t(msg, *args)
        ActiveSupport::Deprecation.warn('`Alchemy::I18n.t` is deprecated! Use `Alchemy.t` instead.', caller.unshift)
        Alchemy::I18n.translate(msg, *args)
      end

      # Alchemy translation methods
      #
      # Instead of having to translate strings and defining a default value:
      #
      #     Alchemy::I18n.translate("Hello World!", default: 'Hello World!')
      #
      # We define this method to define the value only once:
      #
      #     Alchemy::I18n.translate("Hello World!")
      #
      # Note that interpolation still works:
      #
      #     Alchemy::I18n.translate("Hello %{world}!", world: @world)
      #
      # === Notes
      #
      # All translations are scoped into the +alchemy+ namespace.
      # Even scopes are scoped into the +alchemy+ namespace.
      #
      # So a call for Alchemy::translate('hello', scope: 'world') has to be translated like this:
      #
      #   de:
      #     alchemy:
      #       world:
      #         hello: Hallo
      #
      def translate(msg, *args)
        options = args.extract_options!
        humanize_default_string!(msg, options)
        scope = alchemy_scoped_scope(options)
        ::I18n.t(msg, options.merge(scope: scope))
      end

      def available_locales
        @@available_locales ||= nil
        @@available_locales || translation_files.collect do |f|
          f.match(/.{2}\.yml$/).to_s.gsub(/\.yml/, '').to_sym
        end
      end

      def available_locales=(locales)
        @@available_locales = Array(locales).map(&:to_sym)
        @@available_locales = nil if @@available_locales.empty?
      end

      def translation_files
        Dir.glob(File.join(File.dirname(__FILE__), '../../config/locales/alchemy.*.yml'))
      end

      private

      def humanize_default_string!(msg, options)
        return if options[:default].present?
        options[:default] = msg.is_a?(Symbol) ? msg.to_s.humanize : msg
      end

      def alchemy_scoped_scope(options)
        default_scope = ['alchemy']
        case options[:scope]
        when Array
          default_scope + options[:scope]
        when String
          default_scope << options[:scope]
        when Symbol
          if options[:scope] != :alchemy
            default_scope << options[:scope]
          end
        else
          default_scope
        end
      end
    end
  end
end
