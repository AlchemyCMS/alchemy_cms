# frozen_string_literal: true

module Alchemy
  module Admin
    class SitesController < ResourcesController
      def create
        @site = Alchemy::Site.new(resource_params)
        if @site.save
          flash[:notice] = Alchemy.t("Please create a default language for this site.")
          redirect_to alchemy.admin_languages_path(site_id: @site)
        else
          render :new
        end
      end

      def destroy
        if @site.destroy
          flash[:notice] = Alchemy.t("Site successfully removed")
        else
          flash[:warning] = @site.errors.full_messages.to_sentence
        end
        do_redirect_to alchemy.admin_sites_path
      end
    end
  end
end
