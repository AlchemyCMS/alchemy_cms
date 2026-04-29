module Alchemy
  module Admin
    class ElementScheduleTimestamps < ViewComponent::Base
      erb_template <<~HTML
        <div class="input">
          <div class="input-row">
            <div class="input-column">
              <label for="element_public_on"><%= Alchemy::Element.human_attribute_name(:public_on) %></label>
              <%= datetime_local_field :element, :public_on, include_seconds: false %>
              <%= error_for(:public_on) %>
            </div>
            <div class="input-column">
              <label for="element_public_until"><%= Alchemy::Element.human_attribute_name(:public_until) %></label>
              <%= datetime_local_field :element, :public_until, include_seconds: false %>
              <%= error_for(:public_until) %>
            </div>
          </div>
        </div>
      HTML

      def initialize(element:)
        @element = element
      end

      private

      def error_for(attribute)
        errors = @element.errors[attribute]
        return unless errors.present?

        tag.span(errors.to_sentence, class: "error")
      end
    end
  end
end
