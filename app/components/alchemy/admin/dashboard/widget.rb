module Alchemy
  module Admin
    module Dashboard
      class Widget < ViewComponent::Base
        erb_template <<~ERB
          <div class="widget <%= @style %>">
            <%= content %>
          </div>
        ERB

        def initialize(style: "default")
          @style = style
        end
      end
    end
  end
end
