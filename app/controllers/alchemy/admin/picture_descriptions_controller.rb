module Alchemy
  module Admin
    class PictureDescriptionsController < Alchemy::Admin::ResourcesController
      def edit
        @picture_description = @picture.descriptions.find_or_initialize_by(language_id: params[:language_id])
      end

      private

      def load_resource
        @picture = Alchemy::Picture.find(params[:picture_id])
      end
    end
  end
end
