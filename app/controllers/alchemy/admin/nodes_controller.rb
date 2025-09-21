# frozen_string_literal: true

module Alchemy
  module Admin
    class NodesController < Admin::ResourcesController
      include Alchemy::Admin::CurrentLanguage

      def index
        @root_nodes = Node.language_root_nodes
      end

      def new
        @node = Node.new(
          parent_id: params[:parent_id],
          language: @current_language
        )
        @clipboard = get_clipboard("nodes")
        @clipboard_items = Node.all_from_clipboard(@clipboard)
      end

      def create
        if turbo_frame_request?
          @page = Alchemy::Page.find(resource_params[:page_id])
          @node = @page.nodes.build(resource_params)
          if @node.valid?
            @node.save
            flash_notice_for_resource_action(:create)
          else
            flash[:error] = @node.errors.full_messages.join(", ")
          end
        elsif params[:paste_from_clipboard]
          begin
            @node = paste_from_clipboard
            if @node&.persisted?
              flash_notice_for_resource_action(:create)
              do_redirect_to(admin_nodes_path)
            else
              load_clipboard_items
              render :new, status: :unprocessable_entity
            end
          rescue => e
            flash[:error] = e.message
            new  # Reinitialize instance variables like @node
            render :new, status: :unprocessable_entity
          end
        else
          @node = Node.new(resource_params)
          if @node.save
            flash_notice_for_resource_action(:create)
            do_redirect_to(admin_nodes_path)
          else
            load_clipboard_items
            render :new, status: :unprocessable_entity
          end
        end
      end

      def destroy
        if turbo_frame_request?
          @node = Alchemy::Node.find(params[:id])
          @page = @node.page
          @page.nodes.destroy(@node)
          flash_notice_for_resource_action(:destroy)
        else
          super
        end
      end

      private

      def load_clipboard_items
        @clipboard = get_clipboard("nodes")
        @clipboard_items = Node.all_from_clipboard(@clipboard)
      end

      def paste_from_clipboard
        if params[:paste_from_clipboard]
          source = Node.find(params[:paste_from_clipboard])
          parent = Node.find_by(id: params[:node][:parent_id])
          Node.copy_and_paste(source, parent, params[:node][:name])
        end
      end

      def resource_params
        params.require(:node).permit(
          :menu_type,
          :parent_id,
          :language_id,
          :page_id,
          :name,
          :url,
          :title,
          :nofollow,
          :external
        )
      end
    end
  end
end
