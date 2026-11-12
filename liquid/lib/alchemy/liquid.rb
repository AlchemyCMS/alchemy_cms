# frozen_string_literal: true

require "liquid"
require "alchemy/liquid/version"

module Alchemy
  # Opt-in Liquid template support for element views and page layouts.
  #
  # Note: inside the +Alchemy+ namespace +Liquid+ resolves to this module,
  # so the Liquid gem must always be referenced as +::Liquid+.
  module Liquid
    autoload :Drops, "alchemy/liquid/drops"
    autoload :Filters, "alchemy/liquid/filters"
    autoload :Handler, "alchemy/liquid/handler"
    autoload :Tags, "alchemy/liquid/tags"

    class << self
      # The Liquid environment all Alchemy Liquid templates are parsed with.
      #
      # It is built lazily and frozen afterwards. Use {.configure_environment}
      # to register your own tags and filters.
      #
      # @return [::Liquid::Environment]
      def environment
        @environment ||= build_environment
      end

      # Register additional tags or filters for Alchemy Liquid templates.
      #
      #   # config/initializers/alchemy_liquid.rb
      #   Alchemy::Liquid.configure_environment do |env|
      #     env.register_filter(MyFilters)
      #     env.register_tag("my_tag", MyTag)
      #   end
      #
      def configure_environment(&block)
        environment_extensions << block
        reset_environment!
      end

      # Discards the built environment and every parsed template.
      def reset_environment!
        @environment = nil
        Handler.clear_cache!
      end

      # Wraps Alchemy records into their read-only drops. Hashes and arrays
      # are wrapped recursively. Values Liquid cannot handle are dropped.
      def to_drop(object)
        case object
        when ::Liquid::Drop then object
        when Alchemy::Element then Drops::ElementDrop.new(object)
        when Alchemy::Ingredient then Drops::IngredientDrop.new(object)
        when Alchemy::Page then Drops::PageDrop.new(object)
        when Alchemy::Node then Drops::NodeDrop.new(object)
        when Hash then object.to_h { |key, value| [key.to_s, to_drop(value)] }
        when Array, ActiveRecord::Relation then object.map { to_drop(_1) }
        when ActiveRecord::Base then nil
        else
          object.respond_to?(:to_liquid) ? object : nil
        end
      end

      # Returns the Alchemy record wrapped by a drop, or the object itself.
      def unwrap(object)
        object.is_a?(Drops::Base) ? object.record : object
      end

      private

      def environment_extensions
        @environment_extensions ||= []
      end

      def build_environment
        ::Liquid::Environment.build(error_mode: :strict) do |env|
          Tags.register(env)
          env.register_filter(Filters)
          environment_extensions.each { _1.call(env) }
        end
      end
    end
  end
end

require "alchemy/liquid/engine" if defined?(Rails::Engine)
