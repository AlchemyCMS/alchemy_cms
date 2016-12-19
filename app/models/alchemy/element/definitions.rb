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
        @definitions ||= loader.load_all
      end

      # Returns one element definition by given name.
      #
      def definition_by_name(name)
        definitions.detect { |d| d['name'] == name }
      end

      private

      def loader
        @loader ||= ConfigLoader.new('elements')
      end

    end

    # The definition of this element.
    #
    def definition
      if definition = self.class.definitions.detect { |d| d['name'] == name }
        definition
      else
        log_warning "Could not find element definition for #{name}. Please check your elements.yml file!"
        return {}
      end
    end
  end
end
