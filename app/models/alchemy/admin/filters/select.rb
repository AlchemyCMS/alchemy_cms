# frozen_string_literal: true

module Alchemy
  module Admin
    module Filters
      class Select < Base
        attr_reader :options

        # Creates a resource filter that displays as a select.
        # @param name [String] The name of the filter.
        # @param resource_name [String] The name of the resource.
        # @param options [Proc, Array] A proc that returns the options for the select, or an array of options.
        def initialize(name:, resource_name:, options:)
          super(name:, resource_name:)
          @options = options_to_proc(options)
        end

        # Returns a select filter component.
        # @param params [Hash] The search filter params.
        # @param query [Ransack::Search] The current search query.
        # @return [ Alchemy::Admin::Resource::SelectFilter] The select filter component.
        def input_component(params, query)
          Alchemy::Admin::Resource::SelectFilter.new(
            name:,
            resource_name:,
            label: translated_name,
            include_blank:,
            options: get_options_for_select(query),
            params:
          )
        end

        private

        def include_blank
          Alchemy.t(:all, scope: [:filters, resource_name, name])
        end

        def options_to_proc(options)
          if options.is_a? Proc
            options
          else
            ->(_query) { options }
          end
        end

        def get_options_for_select(query)
          options_for_select = options.call(query)
          # The result of the query is an Array of Arrays, where the first element is the translated name and the second element is the value.
          # If the first element is an Array, we assume that the options are already translated.
          if options_for_select.first.is_a? Array
            options_for_select
          # If the values are translatable, we translate them.
          elsif Alchemy.t(:values, scope: [:filters, resource_name, name])
            options_for_select.map do |value|
              [Alchemy.t(value.to_sym, scope: [:filters, resource_name, name, :values]), value]
            end
          # Otherwise we return the options as they are.
          else
            options_for_select.map { |option| [option, option] }
          end
        end

        def translated_value(value, query)
          get_options_for_select(query).detect { |option| option[1].to_s == value }&.first
        end
      end
    end
  end
end
