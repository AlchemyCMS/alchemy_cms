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
          page_layout: Config.get(:default_language)['page_layout']
        )
      end

      def switch
        set_alchemy_language(params[:language_id])
        do_redirect_to request.referer || alchemy.admin_dashboard_path
      end

      private

      def load_current_site
        @current_site = Alchemy::Site.current
        if @current_site.nil?
          flash[:warning] = Alchemy.t('Please create a site first.')
          redirect_to admin_sites_path
        end
      end
    end
  end
end
