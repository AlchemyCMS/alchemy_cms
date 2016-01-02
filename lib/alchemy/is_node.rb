module Alchemy
  # Adds is_alchemy_node class method to ActiveRecord models
  module IsNode
    # Extends class methods
    def self.included(base)
      Alchemy::NODE_TYPES ||= {}
      base.extend ClassMethods
    end

    module ClassMethods
      # Converts model into a node that Alchemy can use as navigatable.
      def is_alchemy_node
        # Prevent node type from beeing registered more than once
        unless Alchemy::NODE_TYPES.include?(self.name)
          Alchemy::NODE_TYPES[self.name] = self
        end

        class_eval <<-EOV
          has_many :alchemy_nodes, as: 'navigatable', class_name: 'Alchemy::Node'

          # Returns records for selectbox in the node tree
          # Define this method in your model class
          # It should return a collection of active record objects, that you want your user
          # to be insert as alchemy node.
          # Returns all records as default
          def self.alchemy_navigatables
            all
          end

          # Called by +Alchemy::Node#create_navigatable!+
          # If navigatable_type parameter was set to 'create',
          # then this method on the node type model will be called.
          def self.create_from_alchemy_node(node)
            raise "Can't create #{self.name}. Please implement a `.create_from_alchemy_node(node)` class method!"
          end

          # Called by +Alchemy::Node.before_save+
          #
          # Override this method in your model,
          # so you can update attributes of the node
          def before_save_of_alchemy_node(node)
            return
          end

          # Used in nodes/index.html view to display a
          # representative name of your node.
          def name_for_alchemy_node
            self.try(:name)
          end
        EOV
      end
    end

  end
end

# Inject into ActiveRecord
ActiveRecord::Base.send(:include, Alchemy::IsNode)
