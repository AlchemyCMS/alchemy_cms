# frozen_string_literal: true

module Alchemy
  module Admin
    module Filters
      class Datepicker < Base
        attr_reader :input_type
        # Creates a resource filter that displays as a datepicker.
        # @param name [String] The name of the filter.
        # @param resource_name [String] The name of the resource.
        # @param input_type [Symbol] The input type of the datepicker. Can be :date, :datetime, or :time.
        # @example
        #  Alchemy::Admin::Filters::Datepicker.new(
        #  name: :created_at_lt,
        #  resource_name: :events,
        #  mode: :single,
        #  default: "2023-01-01"
        def initialize(name:, resource_name:, input_type: :datetime)
          super(name:, resource_name:)
          @input_type = input_type
        end

        # Returns a datepicker filter component.
        # @param params [Hash] The search filter params.
        # @param query [Ransack::Search] The current search query.
        # @return [Alchemy::Admin::Resource::DatepickerFilter] The datepicker filter component.
        def input_component(params, _query)
          Alchemy::Admin::Resource::DatepickerFilter.new(
            name:,
            label: translated_name,
            input_type: @input_type,
            params:
          )
        end

        private

        def translated_value(value, query)
          date = Time.zone.parse(value) if value.is_a?(String)
          format = case input_type
          when :date
            ::I18n.t(:default, scope: [:date, :formats, :alchemy])
          when :datetime
            ::I18n.t(:default, scope: [:time, :formats, :alchemy])
          when :time
            ::I18n.t(:time, scope: [:time, :formats, :alchemy])
          end
          ::I18n.l(date, format: format)
        end
      end
    end
  end
end
