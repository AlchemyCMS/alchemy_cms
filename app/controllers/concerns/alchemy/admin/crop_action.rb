# frozen_string_literal: true

module Alchemy
  module Admin
    module CropAction
      extend ActiveSupport::Concern

      included do
        before_action :load_croppable_resource, only: [:crop]
      end

      def crop
        @picture = Alchemy::Picture.find_by(id: params[:picture_id])
        if @picture
          @croppable_resource.picture = @picture
          @settings = @croppable_resource.image_cropper_settings
          @element = @croppable_resource.element
        else
          @no_image_notice = Alchemy.t(:no_image_for_cropper_found)
        end

        render template: "alchemy/admin/crop"
      end
    end
  end
end
