module Alchemy
  module Admin
    class Dashboard::WidgetsController < DashboardController
      MODULE_NAMESPACE = "Alchemy::Admin::Dashboard::Widgets"

      def show
        @id = params[:id]
        @widget = get_widget(@id)
      end

      private

      def get_widget(id)
        widget = "#{MODULE_NAMESPACE}::#{id.camelcase}".safe_constantize
        # Constant lookup also finds classes in the ancestors of a widget,
        # e.g. "system_info/template" resolves to a ViewComponent internal.
        return widget if widget.is_a?(Class) && widget.module_parent_name == MODULE_NAMESPACE

        Alchemy::Logger.error "No dashboard widget found for id: #{id}"
        raise ActionController::RoutingError, "No dashboard widget found for id: #{id}"
      end
    end
  end
end
