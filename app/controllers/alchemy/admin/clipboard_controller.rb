module Alchemy
  module Admin
    class ClipboardController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::Clipboard

      def index
        @clipboard = get_clipboard
        @clipboard_items = model_class.all_from_clipboard(@clipboard.all(params[:remarkable_type]))
        respond_to do |format|
          format.html
        end
      end

      def insert
        @clipboard = get_clipboard
        @item = model_class.find(params[:remarkable_id])
        unless @clipboard.contains? params[:remarkable_type], params[:remarkable_id]
          @clipboard.push params[:remarkable_type], {:id => params[:remarkable_id], :action => params[:remove] ? 'cut' : 'copy'}
        end
        update_session
        respond_to do |format|
          format.js
        end
      end

      def remove
        @clipboard = get_clipboard
        @item = model_class.find(params[:remarkable_id])
        @clipboard.remove params[:remarkable_type], params[:remarkable_id]
        update_session
        respond_to do |format|
          format.js
        end
      end

      def clear
        @clipboard = get_clipboard
        @clipboard.clear(params[:remarkable_type])
        update_session
      end

    private

      def model_class
        "alchemy/#{params[:remarkable_type]}".classify.constantize
      end

      def update_session
        session[:clipboard] = @clipboard.items
      end

    end
  end
end
