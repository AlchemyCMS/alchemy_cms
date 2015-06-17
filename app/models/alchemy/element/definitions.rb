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
        @definitions ||= read_definitions_file
      end
      alias_method :descriptions, :definitions

      # Returns one element definition by given name.
      #
      def definition_by_name(name)
        definitions.detect { |d| d['name'] == name }
      end

      private

      # Reads the element definitions file named +elements.yml+ from +config/alchemy/+ folder.
      #
      def read_definitions_file
        if ::File.exists?(definitions_file_path)
          ::YAML.load(ERB.new(File.read(definitions_file_path)).result) || []
        else
          raise LoadError, "Could not find elements.yml file! Please run `rails generate alchemy:scaffold`"
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
        log_warning "Could not find element definition for #{self.name}. Please check your elements.yml file!"
        return {}
      end
    end
    alias_method :description, :definition

  end
end
