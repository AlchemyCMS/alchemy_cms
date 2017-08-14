# frozen_string_literal: true

module Alchemy
  class Admin::LegacyPageUrlsController < Alchemy::Admin::ResourcesController
    before_action :load_page

    def new
      @legacy_page_url = @page.legacy_urls.build
    end

    def create
      @legacy_page_url = @page.legacy_urls.build(legacy_page_url_params)
      @legacy_page_url.save
    end

    def update
      @legacy_page_url = LegacyPageUrl.find(params[:id])
      if @legacy_page_url.update(legacy_page_url_params)
        render :update
      else
        render :edit
      end
    end

    def destroy
      @legacy_page_url = LegacyPageUrl.find(params[:id])
      @legacy_page_url.destroy
    end

    private

    def load_page
      @page = Page.find(params[:page_id])
    end

    def legacy_page_url_params
      params.require(:legacy_page_url).permit(:urlname)
    end
  end
end
