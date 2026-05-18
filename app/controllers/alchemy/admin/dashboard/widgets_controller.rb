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
        "#{MODULE_NAMESPACE}::#{id.camelcase}".constantize
      rescue NameError => e
        Alchemy::Logger.error "No dashboard widget found for id: #{id}"
        raise ActionController::RoutingError, e.message
      end
    end
  end
end
