# frozen_string_literal: true

module Alchemy
  # Module concerning element definitions
  #
  module Element::Definitions
    extend ActiveSupport::Concern

    module ClassMethods
      # Returns the definitions from elements.yml file.
      #
      # Place a +elements.yml+ file inside your apps +config/alchemy+ folder to define
      # your own set of elements
      #
      def definitions
        @definitions ||= read_definitions_file.map(&:with_indifferent_access)
      end

      # Returns one element definition by given name.
      #
      def definition_by_name(name)
        definitions.detect { |d| d['name'] == name }
      end

      private

      # Reads the element definitions file named +elements.yml+ from +config/alchemy/+ folder.
      #
      def read_definitions_file
        if ::File.exist?(definitions_file_path)
          ::YAML.safe_load(ERB.new(File.read(definitions_file_path)).result, YAML_WHITELIST_CLASSES, [], true) || []
        else
          raise LoadError, "Could not find elements.yml file! Please run `rails generate alchemy:install`"
        end
      end

      # Returns the +elements.yml+ file path
      #
      def definitions_file_path
        Rails.root.join 'config/alchemy/elements.yml'
      end
    end

    # The definition of this element.
    #
    def definition
      if definition = self.class.definitions.detect { |d| d['name'] == name }
        definition
      else
        log_warning "Could not find element definition for #{name}. Please check your elements.yml file!"
        {}
      end
    end
  end
end
