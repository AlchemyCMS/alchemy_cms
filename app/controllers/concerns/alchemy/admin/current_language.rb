# frozen_string_literal: true

module Alchemy
  module Admin
    module CurrentLanguage
      extend ActiveSupport::Concern

      included do
        prepend_before_action :redirect_to_accessible_site_language, only: :index
        before_action :load_current_language
      end

      private

      def current_alchemy_user_with_languages
        UserWithLanguages.new(current_alchemy_user)
      end

      # If the current alchemy user has not been given access to the current site/language, change them to ones the user has access to.
      def redirect_to_accessible_site_language
        if Alchemy::Language.current
          if current_alchemy_user_with_languages.accessible_sites.exclude? Alchemy::Site.current
            set_alchemy_language current_alchemy_user_with_languages.accessible_languages.first
            @current_alchemy_site = Language.current.site
            set_current_alchemy_site
          elsif current_alchemy_user_with_languages.accessible_languages.exclude? Alchemy::Language.current
            set_alchemy_language current_alchemy_user_with_languages.accessible_languages.on_current_site.first
          end
        end
      end

      def load_current_language
        @current_language = Alchemy::Language.current
        if @current_language.nil?
          flash[:warning] = Alchemy.t("Please create a language first.")
          redirect_to admin_languages_path
        end
      end
    end
  end
end
