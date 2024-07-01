# frozen_string_literal: true

module Alchemy
  module Admin
    module CurrentLanguage
      extend ActiveSupport::Concern

      included do
        # This needs to happen before BaseController#current_alchemy_site sets the session value.
        prepend_before_action :clear_current_language_from_session, if: :switching_site?, only: :index
        before_action :load_current_language
      end

      private

      def switching_site?
        params[:site_id].present? && (params[:site_id] != session[:alchemy_site_id]&.to_s)
      end

      def clear_current_language_from_session
        session.delete(:alchemy_language_id)
      end

      def load_current_language
        @current_language = if session[:alchemy_language_id].present?
          set_alchemy_language(session[:alchemy_language_id])
        else
          Current.language
        end
        if @current_language.nil?
          flash[:warning] = Alchemy.t("Please create a language first.")
          redirect_to admin_languages_path
        end
      end
    end
  end
end
