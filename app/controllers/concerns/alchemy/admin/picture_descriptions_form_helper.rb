module Alchemy
  module Admin
    module PictureDescriptionsFormHelper
      extend ActiveSupport::Concern

      included do
        helper_method :description_field_name_prefix
      end

      def description_field_name_prefix
        picture_description_counter = @picture.descriptions.index(@picture_description)
        "picture[descriptions_attributes][#{picture_description_counter}]"
      end
    end
  end
end
