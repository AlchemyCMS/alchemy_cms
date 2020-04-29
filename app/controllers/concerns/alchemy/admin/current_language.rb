# frozen_string_literal: true

module Alchemy
  module Admin
    module CurrentLanguage
      extend ActiveSupport::Concern

      included do
        before_action :load_current_language
      end

      private

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
