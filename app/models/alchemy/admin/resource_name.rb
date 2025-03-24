# frozen_string_literal: true

module Alchemy
  module Admin
    module ResourceName
      def resource_model_name
        resource_array.join("/").classify
      end

      def resource_name
        resources_name.singularize
      end

      def resource_array
        controller_path_array.reject { |el| el == "admin" }
      end

      def resources_name
        resource_array.last
      end

      def controller_path_array
        controller_path.split("/")
      end
    end
  end
end
