# frozen_string_literal: true

module Alchemy
  # The persisted version of a rendered picture variant
  #
  # You can configure the generator class to implement a
  # different thumbnail store (ie. a remote file storage).
  #
  #     config/initializers/alchemy.rb
  #     Alchemy::PictureThumb.generator_class = My::ThumbnailGenerator
  #
  class PictureThumb < BaseRecord
    belongs_to :picture, class_name: "Alchemy::Picture"

    validates :signature, presence: true
    validates :uid, presence: true
  end
end
