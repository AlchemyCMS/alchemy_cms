# frozen_string_literal: true

module Alchemy
  class Admin::LegacyPageUrlsController < Alchemy::Admin::ResourcesController
    before_action :load_page

    def new
      @legacy_page_url = @page.legacy_urls.build
    end

    def create
      @legacy_page_url = @page.legacy_urls.create(legacy_page_url_params)
      @message = message_for_resource_action
    end

    def show
    end

    def update
      @legacy_page_url = LegacyPageUrl.find(params[:id])
      if @legacy_page_url.update(legacy_page_url_params)
        @message = message_for_resource_action
        render :update
      else
        render :edit
      end
    end

    def destroy
      @page.legacy_urls.destroy(@legacy_page_url)
      @message = message_for_resource_action
    end

    private

    def load_page
      @page = Page.find(params[:page_id])
    end

    def load_resource
      @legacy_page_url = LegacyPageUrl.find(params[:id])
    end

    def legacy_page_url_params
      params.require(:legacy_page_url).permit(:urlname)
    end
  end
end
