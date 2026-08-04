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
        # @param multiple [Boolean, Proc] Whether multiple values can be selected, or a proc called with the search filter params that returns a Boolean.
        # @param include_blank [Boolean, String, Proc] Whether (or with what label) to include a blank option, or a proc called with the search filter params that returns a Boolean/String.
        def initialize(name:, resource_name:, options:, multiple: false, include_blank: true)
          super(name:, resource_name:)
          @options = options_to_proc(options)
          @multiple = bool_or_proc(multiple)
          @include_blank = bool_or_proc(include_blank)
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
            include_blank: include_blank(params),
            options: get_options_for_select(query, params),
            multiple: multiple?(params),
            params:
          )
        end

        # `multiple` can be enabled dynamically via a Proc, so both the
        # scalar and array shape of the submitted value need to be permitted.
        def permitted_search_params
          [name, {name => []}]
        end

        private

        def multiple?(params)
          @multiple.call(params)
        end

        def include_blank(params)
          value = @include_blank.call(params)
          return value unless value == true

          Alchemy.t(:all, scope: [:filters, resource_name, name])
        end

        def bool_or_proc(value)
          value.is_a?(Proc) ? value : ->(_params) { value }
        end

        def options_to_proc(options)
          if options.is_a? Proc
            options
          else
            ->(_query) { options }
          end
        end

        def get_options_for_select(query, params = nil)
          options_for_select = (options.arity == 1) ? options.call(query) : options.call(query, params)
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
