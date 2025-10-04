module Alchemy
  module Admin
    # Renders a locale select tag for switching the backend locale.
    class LocaleSelect < ViewComponent::Base
      attr_reader :name

      def initialize(name = :change_locale)
        @name = name
      end

      def call
        select_tag(
          name,
          options_for_select(
            translations_for_select,
            ::I18n.locale
          )
        )
      end

      def render?
        available_locales.many?
      end

      private

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
