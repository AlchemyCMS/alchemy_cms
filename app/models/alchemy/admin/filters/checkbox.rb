# frozen_string_literal: true

module Alchemy
  module Admin
    module Filters
      class Checkbox < Base
        # Renders a checkbox filter input.
        # @param [Hash] params The controller params.
        # @param [Ransack::Search] _query The current search query.
        # @return [Alchemy::Admin::FilterInputs::Checkbox] The checkbox filter input component.
        def input_component(params, _query)
          Alchemy::Admin::Resource::CheckboxFilter.new(name:, label: translated_name, search_form:, params:)
        end
      end
    end
  end
end
