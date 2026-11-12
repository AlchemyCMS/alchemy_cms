# frozen_string_literal: true

module Alchemy
  module Liquid
    module Drops
      # Base class of all Alchemy drops.
      #
      # Drops are read-only and expose a curated set of attributes. Every
      # public method defined in a subclass is callable from templates,
      # except {#record}, which is reserved for tags and filters.
      #
      # Text values are HTML escaped. Use the +ingredient+ tag to render
      # markup, it delegates to the ingredient's view component.
      class Base < ::Liquid::Drop
        INTERNAL_METHODS = %w[record].freeze

        def self.invokable_methods
          @alchemy_invokable_methods ||= super - INTERNAL_METHODS
        end

        # The wrapped Alchemy record. Not accessible from templates.
        attr_reader :record

        def initialize(record)
          @record = record
        end

        def id
          record.id
        end

        def ==(other)
          other.class == self.class && other.record == record
        end
        alias_method :eql?, :==

        def hash
          [self.class, record].hash
        end

        def inspect
          "#<#{self.class.name} #{record.class.name}##{record.id}>"
        end

        private

        def escape(value)
          value.is_a?(String) ? ERB::Util.html_escape(value) : value
        end

        def drop(object)
          Alchemy::Liquid.to_drop(object)
        end
      end
    end
  end
end
