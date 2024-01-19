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
        else
          super
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
