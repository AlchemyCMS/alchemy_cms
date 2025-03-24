# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      class SelectFilter < ViewComponent::Base
        attr_reader :name, :resource_name, :label, :include_blank, :options, :selected

        erb_template <<~ERB
          <div class="filter-input">
            <%= label_tag select_name, label %>
            <%= select_tag(
              select_name,
              options_for_select(options, selected),
              include_blank: include_blank,
              form: "resource_search",
              is: 'alchemy-select'
            ) %>
          </div>
        ERB

        def initialize(name:, resource_name:, label:, include_blank:, options:, params:)
          @name = name
          @options = options
          @label = label
          @include_blank = include_blank
          @resource_name = resource_name
          @selected = get_selected_value_from(params)
        end

        private

        def get_selected_value_from(params)
          params.dig(:q, name)
        end

        def select_name
          "q[#{name}]"
        end
      end
    end
  end
end
