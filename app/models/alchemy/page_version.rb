module Alchemy
  class PageVersion < ActiveRecord::Base
    belongs_to :page,
      class_name: 'Alchemy::Page',
      inverse_of: :versions,
      required: true

    has_many :elements, -> { order(:position) },
      class_name: 'Alchemy::Element',
      inverse_of: :page_version
  end
end
