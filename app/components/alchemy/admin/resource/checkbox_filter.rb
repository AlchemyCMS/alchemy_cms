# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      class CheckboxFilter < ViewComponent::Base
        attr_reader :name, :label, :checked, :search_form

        erb_template <<~ERB
          <div class="filter-input">
            <label>
              <%= check_box_tag checkbox_name, form: search_form, checked: checked %>
              <%= label %>
            </label>
          </div>
        ERB

        def initialize(name:, label:, search_form:, params:)
          @name = name
          @label = label
          @search_form = search_form
          @checked = get_checked_from(params)
        end

        private

        def get_checked_from(params)
          params.dig(:q, name)
        end

        def checkbox_name
          "q[#{name}]"
        end
      end
    end
  end
end
