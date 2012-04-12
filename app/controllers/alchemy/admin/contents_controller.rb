module Alchemy
  module Admin
    class ContentsController < Alchemy::Admin::BaseController

      def new
        @element = Element.find(params[:element_id])
        @contents = @element.available_contents
        @content = @element.contents.build
        render :layout => false
      end

      def create
        @element = Element.find(params[:content][:element_id])
        @content = Content.create_from_scratch(@element, params[:content])
        @options = params[:options] || {}
        @html_options = params[:html_options] || {}
        # If options params come from Flash uploader then we have to parse them as hash.
        if @options.is_a?(String)
          @options = Rack::Utils.parse_query(@options)
        end
        if @content.essence_type == "Alchemy::EssencePicture"
          @element_dom_id = "#add_content_#{@element.id}"
          @content.essence.picture_id = params[:picture_id]
          @content.essence.save
          @contents_of_this_type = @element.contents.find_all_by_essence_type('Alchemy::EssencePicture')
          @dragable = @contents_of_this_type.length > 1
          @options = @options.merge(:dragable => @dragable)
        else
          @element_dom_id = "#add_content_for_element_#{@element.id}"
        end
        @locals = {
          :content => @content,
          :options => @options.symbolize_keys,
          :html_options => @html_options.symbolize_keys
        }
      end

      def update
        content = Content.find(params[:id])
        content.essence.update_attributes(params[:content])
      end

      def order
        params[:content_ids].each do |id|
          content = Content.find(id)
          content.move_to_bottom
        end
        @notice = t("Successfully saved content position")
      end

      def destroy
        @content = Content.find(params[:id])
        @content_dup = @content.clone
        element = @content.element
        content_name = @content.name
        @notice = t("Successfully deleted content", :content => content_name)
        @content.destroy
      end

    end
  end
end
