module Alchemy
  module Admin
    class ClipboardController < Alchemy::Admin::BaseController
      authorize_resource class: :alchemy_admin_clipboard
      before_filter :set_clipboard

      def index
        @clipboard_items = model_class.all_from_clipboard(@clipboard)
        respond_to do |format|
          format.html
        end
      end

      def insert
        @item = model_class.find(params[:remarkable_id])
        unless @clipboard.detect { |item| item['id'] == params[:remarkable_id] }
          @clipboard << {
            'id' => params[:remarkable_id],
            'action' => params[:remove] ? 'cut' : 'copy'
          }
        end
        respond_to do |format|
          format.js
        end
      end

      def remove
        @item = model_class.find(params[:remarkable_id])
        @clipboard.delete_if { |item| item['id'] == params[:remarkable_id] }
        respond_to do |format|
          format.js
        end
      end

      def clear
        @clipboard.clear
      end

      private

      def set_clipboard
        @clipboard = get_clipboard(params[:remarkable_type])
      end

      def model_class
        "alchemy/#{params[:remarkable_type]}".classify.constantize
      end

    end
  end
end
