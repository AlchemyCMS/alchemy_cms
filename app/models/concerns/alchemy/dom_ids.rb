# frozen_string_literal: true

module Alchemy
  module DomIds
    extend ActiveSupport::Concern

    RESERVED_ANCHOR_SETTING_VALUES = %w[false from_value true]

    included do
      before_validation :parameterize_dom_id,
        if: -> { settings[:anchor].to_s == "true" }
      before_validation :set_dom_id_from_value,
        if: -> { settings[:anchor].to_s == "from_value" }
      before_validation :set_dom_id_to_fixed_value,
        if: -> { !RESERVED_ANCHOR_SETTING_VALUES.include? settings[:anchor].to_s }
    end

    private

    def parameterize_dom_id
      self.dom_id = dom_id&.parameterize
    end

    def set_dom_id_from_value
      self.dom_id = value&.parameterize
    end

    def set_dom_id_to_fixed_value
      self.dom_id = settings[:anchor]&.parameterize
    end
  end
end
