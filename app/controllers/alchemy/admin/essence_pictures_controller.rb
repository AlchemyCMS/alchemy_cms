module Alchemy
  module Admin
    class EssencePicturesController < Alchemy::Admin::BaseController
      load_and_authorize_resource class: Alchemy::EssencePicture

      before_filter :load_content, only: [:edit, :update, :assign]
      before_filter :load_options

      helper 'alchemy/admin/contents'
      helper 'alchemy/admin/essences'
      helper 'alchemy/admin/picture_styles'
      helper 'alchemy/url'

      def edit
      end

      def update
        @essence_picture.update(essence_picture_params)
      end

      # Assigns picture, but does not saves it.
      #
      # When the user saves the element the content gets updated as well.
      #
      def assign
        @picture = Picture.find_by(id: params[:picture_id])
        @content.essence.picture = @picture
        @element = @content.element
        @dragable = @options[:grouped]
        @options = @options.merge(dragable: @dragable)

        # We need to update timestamp here because we don't save yet,
        # but the cache needs to be get invalid.
        # And we don't user @content.touch here, because that updates
        # also the element and page timestamps what we don't want yet.
        @content.update_column(:updated_at, Time.now)
      end

      def destroy
        @content = Content.find_by(id: params[:id])
        @element = @content.element
        @content_id = @content.id
        @content.destroy
        @essence_pictures = @element.contents.essence_pictures
      end

      private

      def load_options
        @options = options_from_params
      end

      def load_content
        @content = Content.find(params[:content_id])
      end

      def essence_picture_params
        params.require(:essence_picture).permit(:alt_tag, :caption, :css_class, :title)
      end

    end
  end
end
