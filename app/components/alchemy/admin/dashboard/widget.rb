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

        def initialize(id:, loading: "eager", style: "default")
          @id = id
          @loading = loading
          @style = style
        end

        private

        def url = alchemy.admin_dashboard_widget_path(id: @id)
      end
    end
  end
end
