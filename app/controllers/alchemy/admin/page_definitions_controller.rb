module Alchemy
  module Admin
    class PageDefinitionsController < ResourcesController
      def index
        filter_params = params.fetch(:q, {}).permit(:name_eq, :name_or_elements_cont)
        @page_type = filter_params[:name_eq].presence
        @query = filter_params[:name_or_elements_cont].presence
        @all_page_definitions = PageDefinition.all.partition { !_1.layoutpage }.flatten
        @page_definitions = @page_type ? @all_page_definitions.select { _1.name == @page_type } : @all_page_definitions
        @page_counts = Page.group(:page_layout).count
        @element_counts_by_page_layout = Element.joins(page_version: :page).merge(PageVersion.draft)
          .group(Page.arel_table[:page_layout], :name).count
        @element_counts = @element_counts_by_page_layout.each_with_object(Hash.new(0)) do |((_page_layout, name), count), totals|
          totals[name] += count
        end
      end

      private

      def resource_handler
        @_resource_handler ||= ::Alchemy::Resource.new(controller_path, alchemy_module, PageDefinition)
      end
    end
  end
end
