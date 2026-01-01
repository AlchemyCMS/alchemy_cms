# frozen_string_literal: true

module Alchemy
  module Admin
    class ClipboardController < Alchemy::Admin::BaseController
      include Alchemy::Admin::Clipboard

      REMARKABLE_TYPES = %w[elements pages nodes]

      authorize_resource class: :alchemy_admin_clipboard

      helper_method :remarkable_type

      def index
        raise ActionController::BadRequest unless remarkable_type

        @clipboard_items = clipboard_items

        respond_to do |format|
          format.html
        end
      end

      def insert
        @item = model_class.find(remarkable_params[:remarkable_id])
        unless clipboard.detect { |item| item["id"] == remarkable_params[:remarkable_id] }
          clipboard << {
            "id" => remarkable_params[:remarkable_id],
            "action" => params[:remove] ? "cut" : "copy"
          }
        end
      end

      def remove
        @item = model_class.find(remarkable_params[:remarkable_id])
        remove_resource_from_clipboard(@item)
      end

      def clear
        clipboard.clear
      end

      private

      def model_class
        raise ActionController::BadRequest unless remarkable_type

        "alchemy/#{remarkable_type}".classify.constantize
      end

      def clipboard_type
        remarkable_type
      end

      def remarkable_params
        params.permit(:remarkable_type, :remarkable_id)
      end

      def remarkable_type
        remarkable_params.keep_if { |_k, type| type.in? REMARKABLE_TYPES }[:remarkable_type]
      end
    end
  end
end
