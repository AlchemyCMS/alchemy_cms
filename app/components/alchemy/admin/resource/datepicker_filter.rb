# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      class DatepickerFilter < ViewComponent::Base
        attr_reader :name, :label, :value, :input_type

        erb_template <<~ERB
          <div class="filter-input">
            <%= label_tag datepicker_name, label %>
            <alchemy-datepicker input_type="<%= input_type %>">
              <%= text_field_tag(
                datepicker_name,
                value,
                form: "resource_search"
              ) %>
            </alchemy-datepicker>
          </div>
        ERB

        def initialize(name:, label:, input_type: :datetime, params: {})
          @name = name
          @label = label
          @input_type = input_type
          @params = params
          @value = get_value(params)
        end

        private

        def get_value(params)
          params.dig(:q, name)
        end

        def datepicker_name
          "q[#{name}]"
        end
      end
    end
  end
end
