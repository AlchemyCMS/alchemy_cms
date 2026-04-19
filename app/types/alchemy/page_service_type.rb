# frozen_string_literal: true

module Alchemy
  class PageServiceType < ActiveModel::Type::Value
    def cast(value)
      return nil if value.nil?

      value.constantize
    rescue NameError
      raise ArgumentError, "Service class \"#{value}\" could not be found."
    end

    def assert_valid_value(value)
      return if value.nil?

      begin
        klass = value.constantize
      rescue NameError
        raise ArgumentError, "Service class \"#{value}\" could not be found. Make sure it is defined and available."
      end

      unless klass < BasePageService
        raise ArgumentError, "Service class \"#{value}\" must be a subclass of Alchemy::BasePageService."
      end
    end
  end
end
