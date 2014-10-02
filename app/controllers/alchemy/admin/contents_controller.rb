module Alchemy
  module Admin
    class ContentsController < Alchemy::Admin::BaseController
      helper 'alchemy/admin/essences'

      authorize_resource class: Alchemy::Content

      def new
        @element = Element.find(params[:element_id])
        @options = options_from_params
        @contents = @element.available_contents
        @content = @element.contents.build
      end

      def create
        @element = Element.find(params[:content][:element_id])
        @content = Content.create_from_scratch(@element, content_params)
        @options = options_from_params
        @html_options = params[:html_options] || {}
        if picture_gallery_editor?
          @content.update_essence(picture_id: params[:picture_id])
          @options = options_for_picture_gallery
          @content_dom_id = "#add_picture_#{@element.id}"
        else
          @content_dom_id = "#add_content_for_element_#{@element.id}"
        end
        @locals = essence_editor_locals
      end

      def update
        @content = Content.find(params[:id])
        @content.update_essence(content_params)
      end

      def order
        params[:content_ids].each do |id|
          content = Content.find(id)
          content.move_to_bottom
        end
        @notice = _t("Successfully saved content position")
      end

      def destroy
        @content = Content.find(params[:id])
        @content_dom_id = @content.dom_id
        @notice = _t("Successfully deleted content", content: @content.name_for_label)
        @content.destroy
      end

      private

      def content_params
        params.require(:content).permit(:element_id, :name, :ingredient, :essence_type)
      end

      def picture_gallery_editor?
        params[:content][:essence_type] == 'Alchemy::EssencePicture' && @options[:grouped] == 'true'
      end

      def options_for_picture_gallery
        @gallery_pictures = @element.contents.gallery_pictures
        @dragable = @gallery_pictures.size > 1
        @options.merge(dragable: @dragable)
      end

      def essence_editor_locals
        {
          content: @content,
          options: @options.symbolize_keys,
          html_options: @html_options.symbolize_keys
        }
      end

    end
  end
end
