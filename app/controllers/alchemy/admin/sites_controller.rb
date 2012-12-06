module Alchemy
  module Admin
    class SitesController < BaseController

      def index
        @sites = Site.all
      end

      def new
        @site = Site.new
        render layout: false
      end

      def create
        @site = Site.new(params[:site])
        @site.save

        render_errors_or_redirect(
          @site,
          admin_sites_path,
          t("Site created", :name => @site.name)
        )
      end

      def edit
        @site = Site.find(params[:id])
        render layout: false
      end

      def update
        @site = Site.find(params[:id])
        @site.update_attributes(params[:site])
        render_errors_or_redirect(
          @site,
          admin_sites_path,
          t("Site updated", :name => @site.name)
        )
      end

      def destroy
        @site = Site.find(params[:id])
        @site.destroy

        flash[:notice] = t("Site deleted", :name => @site.name)
        @redirect_url = admin_sites_path
        render :action => :redirect
      end

    end
  end
end
