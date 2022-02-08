# frozen_string_literal: true

module Alchemy
  class ElementDefinition
    class << self
      # Returns the definitions from elements.yml file.
      #
      # Place a +elements.yml+ file inside your apps +config/alchemy+ folder to define
      # your own set of elements
      #
      def all
        @definitions ||= read_definitions_file.map(&:with_indifferent_access)
      end

      # Add additional page definitions to collection.
      #
      # Useful for extending the elements from an Alchemy module.
      #
      # === Usage Example
      #
      #   Call +Alchemy::ElementDefinition.add(your_definition)+ in your engine.rb file.
      #
      # @param [Array || Hash]
      #   You can pass a single element definition as Hash, or a collection of elements as Array.
      #
      def add(element)
        all
        if element.is_a?(Array)
          @definitions += element
        elsif element.is_a?(Hash)
          @definitions << element
        else
          raise TypeError
        end
      end

      # Returns one element definition by given name.
      #
      def get(name)
        return {} if name.blank?

        all.detect { |a| a["name"] == name }
      end

      private

      # Reads the element definitions from +config/alchemy/elements.yml+.
      #
      def read_definitions_file
        if File.exist?(definitions_file_path)
          YAML.safe_load(
            ERB.new(File.read(definitions_file_path)).result,
            YAML_WHITELIST_CLASSES,
            [],
            true
          ) || []
        else
          raise LoadError,
                "Could not find elements.yml file! Please run `rails generate alchemy:install`"
        end
      end

      # Returns the elements.yml file path
      #
      def definitions_file_path
        Rails.root.join "config/alchemy/elements.yml"
      end
    end
  end
end
