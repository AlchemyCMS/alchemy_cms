module ActsAsFerret

  # Include this module to use acts_as_ferret with model classes 
  # not based on ActiveRecord. 
  #
  # Implement the find_for_id(id) class method in your model class in
  # order to make search work.
  module WithoutAR
    def self.included(target)
      target.extend ClassMethods
      target.extend ActsAsFerret::ActMethods
      target.send :include, InstanceMethods
    end

    module ClassMethods
      def logger
        RAILS_DEFAULT_LOGGER
      end
      def table_name
        self.name.underscore
      end
      def primary_key
        'id'
      end
      def find(what, args = {})
        case what
        when :all
          ids = args[:conditions][1]
          ids.map { |id| find id }
        else
          find_for_id what
        end
      end
      def find_for_id(id)
        raise NotImplementedError.new("implement find_for_id in class #{self.name}")
      end
      def count
        0
      end
    end

    module InstanceMethods
      def logger
        self.class.logger
      end
      def new_record?
        false
      end
    end
  end
        
end
