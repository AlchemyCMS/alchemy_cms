module Alchemy
  class ContentSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :ingredient,
      :element_id,
      :position,
      :created_at,
      :updated_at

    has_one :essence, polymorphic: true

    def ingredient
      case object.essence_type
      when 'Alchemy::EssencePicture'
        object.essence.picture_url
      when 'Alchemy::EssenceFile'
        object.essence.attachment_url
      else
        object.ingredient
      end
    end

  end
end
