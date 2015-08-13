module Alchemy
  module Admin
    class PictureStylesController < Alchemy::Admin::BaseController
      load_and_authorize_resource class: Alchemy::PictureStyle
      helper 'alchemy/admin/essences'
      before_filter :load_options

      def edit
        @crop_settings = Alchemy::Admin::CropSettingsService.new(@picture_style, @options)
        @picture = @picture_style.picture
        @options[:format] ||= (configuration(:image_store_format) or 'png')
      end

      def update
        @picture_style.update_attributes(picture_style_params)
        @content = @picture_style.picture_assignment.assignable.content
      end

      private

      def load_options
        @options = options_from_params
      end

      def picture_style_params
        params.require(:picture_style).permit(:render_size, :crop_from, :crop_size)
      end
    end
  end
end
