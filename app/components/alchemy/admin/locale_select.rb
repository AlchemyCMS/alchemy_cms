module Alchemy
  module Admin
    # Renders a locale select tag for switching the backend locale.
    class LocaleSelect < ViewComponent::Base
      attr_reader :name, :auto_submit

      def initialize(name = :admin_locale, auto_submit: true)
        @name = name
        @auto_submit = auto_submit
      end

      def call
        form_tag(helpers.url_for, method: :get) do
          if auto_submit
            content_tag("alchemy-auto-submit", locale_select)
          else
            locale_select
          end
        end
      end

      def render?
        available_locales.many?
      end

      private

      def locale_select
        select_tag(
          name,
          options_for_select(
            translations_for_select,
            ::I18n.locale
          )
        )
      end

      def available_locales
        @_available_locales ||= Alchemy::I18n.available_locales.sort!
      end

      def translations_for_select
        available_locales.map do |locale|
          [Alchemy.t(locale, scope: :translations), locale]
        end
      end
    end
  end
end
