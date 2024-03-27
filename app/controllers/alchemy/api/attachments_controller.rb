# frozen_string_literal: true

module Alchemy
  class Api::AttachmentsController < Api::BaseController
    def index
      authorize! :index, Attachment

      @attachments = Attachment.all
      @attachments = @attachments.ransack(params[:q]).result

      if params[:page]
        @attachments = @attachments.page(params[:page]).per(params[:per_page])
      end

      render json: @attachments, adapter: :json, root: "data", meta: meta_data
    end

    private

    def meta_data
      {
        total_count: total_count_value,
        per_page: per_page_value,
        page: page_value
      }
    end

    def total_count_value
      params[:page] ? @attachments.total_count : @attachments.size
    end

    def per_page_value
      if params[:page]
        (params[:per_page] || Kaminari.config.default_per_page).to_i
      else
        @attachments.size
      end
    end

    def page_value
      params[:page] ? params[:page].to_i : 1
    end
  end
end
