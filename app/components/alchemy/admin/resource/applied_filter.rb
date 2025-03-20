# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      class AppliedFilter < ViewComponent::Base
        attr_reader :label, :link

        erb_template <<~ERB
          <div class="applied-filter">
            <%= label %>
            <%= link_to link, class: 'dismiss-filter' do %>
              <%= render Alchemy::Admin::Icon.new(:times, size: :xs) %>
            <% end %>
          </div>
        ERB

        def initialize(label:, link:)
          @label = label
          @link = link
        end
      end
    end
  end
end
