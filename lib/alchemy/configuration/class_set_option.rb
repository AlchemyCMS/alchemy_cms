# frozen_string_literal: true

require "alchemy/configuration/base_option"

module Alchemy
  class Configuration
    class ClassSetOption < BaseOption
      include Enumerable

      def value = self

      def <<(klass)
        @value << klass.to_s
      end

      def concat(klasses)
        klasses.each do |klass|
          self << klass
        end

        self
      end

      delegate :clear, :empty?, to: :@value

      def delete(object)
        @value.delete(object.to_s)
      end

      def each
        @value.each do |klass|
          yield klass.constantize
        end
      end

      def as_json = @value

      private

      def validate(value)
        raise TypeError, "each #{name} must be set as a String" unless value.all? { _1.is_a?(String) }
        value
      end
    end
  end
end
