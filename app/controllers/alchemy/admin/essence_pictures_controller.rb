module Alchemy
  module Admin
    class EssencePicturesController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::EssencePicture

      before_filter :load_essence_picture, only: [:edit, :crop, :update]
      before_filter :load_content, only: [:edit, :update, :assign]
      before_filter :load_options

      helper 'alchemy/admin/contents'
      helper 'alchemy/admin/essences'
      helper 'alchemy/url'

      def edit
      end

      def crop
        if @picture = @essence_picture.picture
          @content = @essence_picture.content
          @options[:format] ||= (configuration(:image_store_format) or 'png')
          @size_x, @size_y = sizes_from_essence_or_params
          @initial_box, @default_box = cropping_boxes
          @ratio = ratio_from_size_or_params
        else
          @no_image_notice = _t(:no_image_for_cropper_found)
        end
      end

      def update
        @essence_picture.update(essence_picture_params)
      end

      # Assigns picture, but does not saves it.
      #
      # When the user press save on the element, it gets saved.
      #
      def assign
        @picture = Picture.find_by_id(params[:picture_id])
        @content.essence.picture = @picture
        @element = @content.element
        @dragable = @options[:grouped]
        @options = @options.merge(dragable: @dragable)
      end

      def destroy
        @content = Content.find_by_id(params[:id])
        @element = @content.element
        @content_id = @content.id
        @content.destroy
        @essence_pictures = @element.contents.essence_pictures
      end

      private

      def load_options
        @options = options_from_params
      end

      def load_essence_picture
        @essence_picture = EssencePicture.find(params[:id])
      end

      def load_content
        @content = Content.find(params[:content_id])
      end

      def sizes_from_essence_or_params
        sizes_from_essence || sizes_from_params
      end

      def sizes_from_params
        return [0, 0] if @options[:image_size].blank?
        @options[:image_size].split('x')
      end

      def sizes_from_essence
        return if @essence_picture.render_size.blank?
        size_x, size_y = @essence_picture.render_size.split('x').map(&:to_i)
        if size_x.zero? || size_y.nil? || size_y.zero?
          size_x_of_original = @essence_picture.picture.image_file_width 
          size_y_of_original = @essence_picture.picture.image_file_height
          size_x = size_x_of_original * size_y / size_y_of_original if size_x.zero?
          size_y = size_y_of_original * size_x / size_x_of_original if size_y.nil? || size_y.zero?
        end
        [size_x, size_y]
      end

      def sizes_string
        @sizes_string ||= "#{@size_x}x#{@size_y}"
      end

      def cropping_boxes
        if @essence_picture.crop_from.blank? || @essence_picture.crop_size.blank?
          initial_box = @picture.default_mask(sizes_string)
          default_box = initial_box
        else
          initial_box = @essence_picture.cropping_mask
          default_box = @picture.default_mask(sizes_string)
        end
        [initial_box, default_box]
      end

      def ratio_from_size_or_params
        if @options[:fixed_ratio] == false
          false
        elsif @size_y == 0
          1
        else
          @size_x.to_f / @size_y.to_f
        end
      end

      def essence_picture_params
        params.require(:essence_picture).permit(:alt_tag, :caption, :css_class, :render_size, :title, :crop_from, :crop_size)
      end

    end
  end
end
