# frozen_string_literal: true

module Alchemy
  class Element < BaseRecord
    # Module concerning element definitions
    #
    module Definitions
      extend ActiveSupport::Concern

      module ClassMethods
        # Register a custom element definitions repository
        #
        # The default repository is Alchemy::ElementDefinition
        #
        def definitions_repository=(klass)
          @_definitions_repository = klass
        end

        # Returns the definitions from elements.yml file.
        #
        # Place a +elements.yml+ file inside your apps +config/alchemy+ folder to define
        # your own set of elements
        #
        def definitions
          definitions_repository.all
        end

        # Returns one element definition by given name.
        #
        def definition_by_name(name)
          definitions_repository.get(name)
        end

        private

        def definitions_repository
          @_definitions_repository ||= ElementDefinition
        end
      end

      # The definition of this element.
      #
      def definition
        if definition = self.class.definition_by_name(name)
          definition
        else
          log_warning "Could not find element definition for #{name}. " \
                      "Please check your elements.yml file!"
          {}
        end
      end
    end
  end
end
