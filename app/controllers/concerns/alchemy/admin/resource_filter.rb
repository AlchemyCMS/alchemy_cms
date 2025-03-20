# frozen_string_literal: true

module Alchemy
  module Admin
    module ResourceFilter
      extend ActiveSupport::Concern
      COMMON_SEARCH_FILTER_EXCLUDES = %i[id utf8 _method _ format].freeze

      included do
        prepend_before_action :initialize_alchemy_filters
        attr_reader :alchemy_filters
        helper_method :alchemy_filters, :search_form_name, :applied_filters, :search_filter_params, :resource_has_filters
      end

      private

      def initialize_alchemy_filters
        @alchemy_filters = []
        return unless resource_model.respond_to?(:alchemy_resource_filters)

        resource_model.alchemy_resource_filters.each do |filter_config|
          if resource_model.respond_to?(filter_config[:name])
            add_alchemy_filter filter_config[:name], type: :select, options: filter_config[:values]
          else
            filter_config[:values].each do |scope|
              add_alchemy_filter scope, type: :checkbox
            end
          end
        end
      end

      # Adds a filter to the resource.
      # @param name [String, Symbol] The name of the filter.
      # @param type [Symbol] The type of the filter. Can currently be `:select` or `:checkbox`.
      # @param args [Hash] Additional arguments for the filter.
      # @example
      #   add_alchemy_filter :by_location, type: :select, options: ->(query) { Location.pluck(:name, :id) }
      #   add_alchemy_filter :future, type: :checkbox
      #   add_alchemy_filter :by_timeframe, type: :select, options: ["today", "tomorrow"]
      def add_alchemy_filter(name, type:, **args)
        alchemy_filters << "Alchemy::Admin::Filters::#{type.to_s.camelize}".constantize.new(
          name:, resource_name:, search_form:, **args
        )
      end

      def search_form
        resource_model.name.underscore + "_search"
      end

      def search_filter_params
        @_search_filter_params ||= params.except(*COMMON_SEARCH_FILTER_EXCLUDES).permit(*common_search_filter_includes).to_h
      end

      def common_search_filter_includes
        [
          {
            q: [:s] + permitted_ransack_search_fields
          },
          :tagged_with,
          :page,
          :per_page
        ]
      end

      def permitted_ransack_search_fields
        [
          resource_handler.search_field_name
        ] + alchemy_filters.map(&:name)
      end

      def resource_has_filters
        alchemy_filters.any?
      end

      def applied_filters
        return [] unless params[:q]

        alchemy_filters.select do |alchemy_filter|
          params[:q][alchemy_filter.name].present?
        end
      end
    end
  end
end
