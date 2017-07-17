# frozen_string_literal: true

module Alchemy
  module Admin
    class ClipboardController < Alchemy::Admin::BaseController
      REMARKABLE_TYPES = %w(elements pages)

      authorize_resource class: :alchemy_admin_clipboard
      before_action :set_clipboard

      def index
        @clipboard_items = model_class.all_from_clipboard(@clipboard)
        respond_to do |format|
          format.html
        end
      end

      def insert
        @item = model_class.find(remarkable_params[:remarkable_id])
        unless @clipboard.detect { |item| item['id'] == remarkable_params[:remarkable_id] }
          @clipboard << {
            'id' => remarkable_params[:remarkable_id],
            'action' => params[:remove] ? 'cut' : 'copy'
          }
        end
        respond_to do |format|
          format.js
        end
      end

      def remove
        @item = model_class.find(remarkable_params[:remarkable_id])
        @clipboard.delete_if { |item| item['id'] == remarkable_params[:remarkable_id] }
        respond_to do |format|
          format.js
        end
      end

      def clear
        @clipboard.clear
      end

      private

      def set_clipboard
        @clipboard = get_clipboard(remarkable_type)
      end

      def model_class
        raise ActionController::BadRequest unless remarkable_type
        "alchemy/#{remarkable_type}".classify.constantize
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
