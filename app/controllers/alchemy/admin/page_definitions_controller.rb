module Alchemy
  module Admin
    class PageDefinitionsController < ResourcesController
      def index
        @page_definitions = PageDefinition.all
      end

      private

      def resource_handler
        @_resource_handler ||= ::Alchemy::Resource.new(controller_path, alchemy_module, PageDefinition)
      end
    end
  end
end
