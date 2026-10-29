# frozen_string_literal: true

module Alchemy
  module Admin
    module ResourceFilter
      extend ActiveSupport::Concern

      COMMON_SEARCH_FILTER_EXCLUDES = %i[id utf8 _method _ format].freeze

      included do
        helper_method :alchemy_filters, :search_form_name, :applied_filters, :search_filter_params, :resource_has_filters
      end

      class_methods do
        # Adds a filter to the resource.
        # @param name [String, Symbol] The name of the filter.
        # @param type [Symbol] The type of the filter. Can currently be `:select` or `:checkbox`.
        # @param args [Hash] Additional arguments for the filter.
        # @example
        #   add_alchemy_filter :by_location, type: :select, options: ->(query) { Location.pluck(:name, :id) }
        #   add_alchemy_filter :future, type: :checkbox
        #   add_alchemy_filter :by_timeframe, type: :select, options: ["today", "tomorrow"]
        #   add_alchemy_filter :by_tag, type: :select, options: ->(query) { Tag.pluck(:name) }, multiple: true, include_blank: false
        #   add_alchemy_filter :by_tag, type: :select, options: ->(query) { Tag.pluck(:name) }, multiple: ->(params) { params[:only].present? }
        def add_alchemy_filter(name, type:, **args)
          alchemy_filters << "Alchemy::Admin::Filters::#{type.to_s.camelize}".constantize.new(
            name:,
            resource_name:,
            **args
          )
        end

        def alchemy_filters
          @alchemy_filters ||= []
        end
      end
      delegate :alchemy_filters, to: :class

      private

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
        ] + alchemy_filters.flat_map(&:permitted_search_params)
      end

      def resource_has_filters
        alchemy_filters.any?
      end

      def applied_filters
        return [] unless search_filter_params[:q]

        alchemy_filters.select do |alchemy_filter|
          search_filter_params[:q][alchemy_filter.name].present?
        end
      end
    end
  end
end
