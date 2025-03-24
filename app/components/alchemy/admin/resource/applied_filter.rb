# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      class AppliedFilter < ViewComponent::Base
        attr_reader :applied_filter_label, :applied_filter_value, :link

        erb_template <<~ERB
          <div class="applied-filter">
            <span class="applied-filter-label">
                <%= applied_filter_label -%><%= ": " if applied_filter_value.present? -%>
              </span>
              <%= applied_filter_value %>
            <%= link_to link, class: 'dismiss-filter' do %>
              <%= render Alchemy::Admin::Icon.new(:times, size: "1x") %>
            <% end %>
          </div>
        ERB

        def initialize(applied_filter_label:, link:, applied_filter_value: nil)
          @applied_filter_label = applied_filter_label
          @link = link
          @applied_filter_value = applied_filter_value
        end
      end
    end
  end
end
