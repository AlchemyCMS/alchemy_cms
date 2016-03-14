module Alchemy
  class PageVersion < ActiveRecord::Base
    belongs_to :page,
      class_name: 'Alchemy::Page',
      inverse_of: :versions,
      required: true

    has_many :elements, -> { order(:position) },
      class_name: 'Alchemy::Element',
      inverse_of: :page_version

    after_destroy :destroy_not_trashed_elements

    private

    def destroy_not_trashed_elements
      elements.not_trashed.destroy_all
    end
  end
end
