# frozen_string_literal: true

module Alchemy
  module Admin
    class ContentsController < Alchemy::Admin::BaseController
      helper 'alchemy/admin/essences'

      authorize_resource class: Alchemy::Content

      def new
        @element = Element.find(params[:element_id])
        @content = @element.contents.build
      end

      def create
        @element = Element.find(params[:content][:element_id])
        @content = Content.create_from_scratch(@element, content_params)
        @html_options = params[:html_options] || {}
        if picture_gallery_editor?
          @content.update_essence(picture_id: params[:picture_id])
          @gallery_pictures = @element.contents.gallery_pictures
          options_from_params[:sortable] = @gallery_pictures.size > 1
          @content_dom_id = "#add_picture_#{@element.id}"
        else
          @content_dom_id = "#add_content_for_element_#{@element.id}"
        end
      end

      def update
        @content = Content.find(params[:id])
        @content.update_essence(content_params)
      end

      def order
        Content.transaction do
          params[:content_ids].each_with_index do |id, idx|
            Content.where(id: id).update_all(position: idx + 1)
          end
        end
        @notice = Alchemy.t("Successfully saved content position")
      end

      def destroy
        @content = Content.find(params[:id])
        @content_dom_id = @content.dom_id
        @notice = Alchemy.t("Successfully deleted content", content: @content.name_for_label)
        @content.destroy
      end

      private

      def content_params
        params.require(:content).permit(:element_id, :name, :ingredient, :essence_type)
      end

      def picture_gallery_editor?
        params[:content][:essence_type] == 'Alchemy::EssencePicture' && options_from_params[:grouped] == 'true'
      end
    end
  end
end
