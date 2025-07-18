# frozen_string_literal: true

module Alchemy
  module Admin
    class LanguagesController < ResourcesController
      before_action :load_current_site, only: %i[index new]

      def index
        @query = Language.on_site(@current_site).ransack(search_filter_params[:q])
        @query.sorts = default_sort_order if @query.sorts.empty?
        @languages = @query.result.page(params[:page] || 1).per(items_per_page)
      end

      def new
        @language = Language.new(
          site: @current_site,
          page_layout: Alchemy.config.default_language.page_layout
        )
      end

      def create
        @language = Alchemy::Language.new(resource_params)
        if @language.save
          flash[:notice] = Alchemy.t("Language successfully created")
          do_redirect_to alchemy.admin_pages_path(language_id: @language)
        else
          render :new
        end
      end

      def destroy
        if @language.destroy
          flash[:notice] = Alchemy.t("Language successfully removed")
        else
          flash[:warning] = @language.errors.full_messages.to_sentence
        end
        do_redirect_to alchemy.admin_languages_path
      end

      def switch
        @language = set_alchemy_language(params[:language_id])
        session[:alchemy_language_id] = @language.id
        do_redirect_to relative_referer_path || alchemy.admin_dashboard_path
      end

      private

      def load_current_site
        @current_site = Alchemy::Current.site
        if @current_site.nil?
          flash[:warning] = Alchemy.t("Please create a site first.")
          do_redirect_to admin_sites_path
        end
      end
    end
  end
end
