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
        if @content.essence_type == "Alchemy::EssencePicture"
          @content_dom_id = "#add_picture_#{@element.id}"
          @content.essence.picture_id = params[:picture_id]
          @content.essence.save
          @contents_of_this_type = @element.contents.gallery_pictures
          @dragable = @contents_of_this_type.size > 1
          @options = @options.merge(dragable: @dragable)
        else
          @content_dom_id = "#add_content_for_element_#{@element.id}"
        end
        @locals = {
          content: @content,
          options: @options.symbolize_keys,
          html_options: @html_options.symbolize_keys
        }
      end

      def update
        content = Content.find(params[:id])
        content.essence.update_attributes(content_params)
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

    end
  end
end
