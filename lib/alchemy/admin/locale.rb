# frozen_string_literal: true

module Alchemy
  module Admin
    module Locale
      extend ActiveSupport::Concern

      included do
        before_action :set_translation
      end

      private

      # Sets Alchemy's GUI translation.
      #
      # Uses the most preferred locale or falls back to the default locale if none of the preferred is available.
      #
      # It respects the default translation from your +config/application.rb+ +default_locale+ config option.
      #
      def set_translation
        if locale_change_needed?
          locale = available_locale || ::I18n.default_locale
        else
          locale = session[:alchemy_locale]
        end
        ::I18n.locale = session[:alchemy_locale] = locale
      end

      # Checks if we need to change to locale or not.
      def locale_change_needed?
        params[:admin_locale].present? || session[:alchemy_locale].blank?
      end

      # Returns either the most preferred locale that is within the list of available locales or nil
      #
      # The availability of the locales is checked in the exact order of either
      #
      #  * the passed parameter: +params[:admin_locale]+
      #  * the user's locale
      #  * the locale of the browser
      #
      def available_locale
        locales = [params[:admin_locale], locale_from_user, locale_from_browser].compact.map(&:to_sym)
        locales.detect { |locale| ::I18n.available_locales.include?(locale) }
      end

      # Try to get the locale from user settings.
      def locale_from_user
        return if !current_alchemy_user
        if user_has_preferred_language?
          current_alchemy_user.language
        end
      end

      # Checks if the +current_alchemy_user+ has a preferred language set or not.
      def user_has_preferred_language?
        return if !current_alchemy_user
        current_alchemy_user.respond_to?(:language) &&
          current_alchemy_user.language.present? &&
          current_alchemy_user.language.respond_to?(:to_sym)
      end

      # Try to get the locale from browser headers.
      def locale_from_browser
        request.env['HTTP_ACCEPT_LANGUAGE'].try(:scan, /\A[a-z]{2}/).try(:first)
      end
    end
  end
end
