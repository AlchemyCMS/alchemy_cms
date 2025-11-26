module Alchemy
  module Admin
    class UpdateCheck < ViewComponent::Base
      erb_template <<-ERB
        <alchemy-update-check url="<%= alchemy.update_check_path %>">
          <span class="update_available hidden">
            <%= render_icon(:exclamation) %>
            <%= Alchemy.t('Update available') %>
          </span>
          <span class="up_to_date hidden">
            <%= render_icon(:check) %>
            <%= Alchemy.t('Alchemy is up to date') %>
          </span>
          <span class="error hidden">
            <%= render_icon(:exclamation) %>
            <%= Alchemy.t('Update status unavailable') %>
          </span>
        </alchemy-update-check>
      ERB

      delegate :alchemy, :can?, :render_icon, to: :helpers

      def render?
        !Rails.env.local? && can?(:update_check, :alchemy_admin_dashboard) &&
          Alchemy.config.update_check_service != :none
      end
    end
  end
end
