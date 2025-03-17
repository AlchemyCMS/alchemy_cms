# frozen_string_literal: true

require "alchemy/resource_filters/select"

module Alchemy
  module ResourceFilters
    def self.build(filter, resource_name)
      filter_class = "Alchemy::ResourceFilters::#{(filter[:type] || "select").camelize}".constantize
      filter_class.new(filter, resource_name)
    end
  end
end
