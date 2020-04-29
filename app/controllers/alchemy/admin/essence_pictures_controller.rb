# frozen_string_literal: true

module Alchemy
  module Admin
    class EssencePicturesController < Alchemy::Admin::BaseController
      FLOAT_REGEX = /\A\d+(\.\d+)?\z/
      authorize_resource class: Alchemy::EssencePicture

      before_action :load_essence_picture, only: [:edit, :crop, :update]
      before_action :load_content, only: [:edit, :update, :assign]

      helper "alchemy/admin/contents"
      helper "alchemy/admin/essences"
      helper "alchemy/url"

      def edit
      end

      def crop
        if @picture = @essence_picture.picture
          @content = @essence_picture.content
          @min_size = sizes_from_essence_or_params
          @ratio = ratio_from_size_or_settings
          infer_width_or_height_from_ratio

          @default_box = @essence_picture.default_mask(@min_size)
          @initial_box = @essence_picture.cropping_mask || @default_box
        else
          @no_image_notice = Alchemy.t(:no_image_for_cropper_found)
        end
      end

      def update
        @essence_picture.update(essence_picture_params)
      end

      # Assigns picture, but does not save it.
      #
      # When the user saves the element the content gets updated as well.
      #
      def assign
        @picture = Picture.find_by(id: params[:picture_id])
        @content.essence.picture = @picture
        @element = @content.element

        # We need to update timestamp here because we don't save yet,
        # but the cache needs to be get invalid.
        @content.touch
      end

      def destroy
        @content = Content.find_by(id: params[:id])
        @element = @content.element
        @content_id = @content.id
        @content.destroy
        @essence_pictures = @element.contents.essence_pictures
      end

      private

      def load_essence_picture
        @essence_picture = EssencePicture.find(params[:id])
      end

      def load_content
        @content = Content.find(params[:content_id])
      end

      # Gets the minimum size of the image to be rendered.
      #
      # The +render_size+ attribute has preference over the contents +size+ setting.
      #
      def sizes_from_essence_or_params
        if @essence_picture.render_size?
          @essence_picture.sizes_from_string(@essence_picture.render_size)
        elsif @essence_picture.content.settings[:size]
          @essence_picture.sizes_from_string(@essence_picture.content.settings[:size])
        else
          { width: 0, height: 0 }
        end
      end

      # Infers the aspect ratio from size or contents settings. If you don't want a fixed
      # aspect ratio, don't specify a size or only width or height.
      #
      def ratio_from_size_or_settings
        if @min_size.value?(0) && @essence_picture.content.settings[:fixed_ratio].to_s =~ FLOAT_REGEX
          @essence_picture.content.settings[:fixed_ratio].to_f
        elsif !@min_size[:width].zero? && !@min_size[:height].zero?
          @min_size[:width].to_f / @min_size[:height]
        else
          false
        end
      end

      # Infers the minimum width or height
      # if the aspect ratio and one dimension is specified.
      #
      def infer_width_or_height_from_ratio
        return unless @ratio

        if @min_size[:height].zero?
          @min_size[:height] = (@min_size[:width] / @ratio).to_i
        else
          @min_size[:width] = (@min_size[:height] * @ratio).to_i
        end
      end

      def essence_picture_params
        params.require(:essence_picture).permit(:alt_tag, :caption, :css_class, :render_size, :title, :crop_from, :crop_size)
      end
    end
  end
end
