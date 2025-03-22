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
          Alchemy::Admin::Resource::CheckboxFilter.new(name:, label: translated_name, params:)
        end

        def applied_filter_component(search_filter_params:, resource_url_proxy:, query:)
          Alchemy::Admin::Resource::AppliedFilter.new(
            link: dismiss_filter_url(search_filter_params, resource_url_proxy),
            applied_filter_label: translated_name
          )
        end
      end
    end
  end
end
