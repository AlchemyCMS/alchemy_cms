# frozen_string_literal: true

module Alchemy
  module Admin
    module Dashboard
      class Widget < ViewComponent::Base
        delegate :alchemy, to: :helpers

        erb_template <<~ERB
          <div class="widget <%= @style %>">
            <turbo-frame id="<%= @id %>" src="<%= url %>" loading="<%= @loading %>">
              <alchemy-spinner size="small"></alchemy-spinner>
            </turbo-frame>
          </div>
        ERB

        def initialize(id:, loading: "eager", style: "default", condition: nil)
          @id = id
          @loading = loading
          @style = style
          @condition = condition

          if condition && !condition.respond_to?(:call)
            raise ArgumentError, ":condition argument must be a proc or lambda"
          end
        end

        private

        def render?
          return true if @condition.nil?

          instance_exec(&@condition)
        end

        def url = alchemy.admin_dashboard_widget_path(id: @id)
      end
    end
  end
end
