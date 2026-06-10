module Alchemy
  class InvalidateElementsCacheJob < BaseJob
    queue_as :default

    def perform(related_object_type, related_object_id)
      element_ids = Ingredient
        .where(related_object_type:, related_object_id:)
        .joins(:element)
        .pluck(:element_id)
      elements = Element.where(id: element_ids)

      all_element_ids = get_all_element_ids(elements, element_ids)
      Element.where(id: all_element_ids).touch_all

      page_ids = elements.joins(page_version: :page).select("DISTINCT alchemy_pages.id")
      Page.where(id: page_ids).touch_all
    end

    private

    def get_all_element_ids(elements, element_ids)
      parent_element_ids = elements.where.not(parent_element_id: nil).pluck(:parent_element_id)
      parent_elements = Element.distinct.where(id: parent_element_ids)

      if parent_elements.any?
        element_ids += parent_element_ids
        get_all_element_ids(parent_elements, element_ids)
      else
        element_ids
      end
    end
  end
end
