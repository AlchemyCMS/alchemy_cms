# frozen_string_literal: true

module Alchemy
  class DeleteElements
    class WouldLeaveOrphansError < StandardError; end
    attr_reader :elements

    def initialize(elements)
      @elements = elements
    end

    def call
      if orphanable_records.present?
        raise WouldLeaveOrphansError
      end

      contents = Alchemy::Content.where(element_id: elements.map(&:id))
      contents.group_by(&:essence_type)
        .transform_values! { |value| value.map(&:essence_id) }
        .each do |class_name, ids|
          class_name.constantize.where(id: ids).delete_all
        end
      contents.delete_all
      delete_elements
    end

    private

    def orphanable_records
      Alchemy::Element.where(parent_element_id: [elements]).where.not(id: elements)
    end

    def delete_elements
      case elements
      when ActiveRecord::Associations::CollectionProxy
        elements.delete_all(:delete_all)
      when ActiveRecord::Relation
        elements.delete_all
      else
        Alchemy::Element.where(id: elements).delete_all
      end
    end
  end
end
