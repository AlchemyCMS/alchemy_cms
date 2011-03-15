module Alchemy #:nodoc:
  module Essence #:nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    # Delivers various methods we need for Essences in Alchemy.
    # To turn a model into an essence call acts_as_essence inside your model and you will get:
    #   * validations
    #   * several getters (ie: page, element, content, ingredient, preview_text)
    module ClassMethods
      
      # Configuration options are:
      #
      # * +ingredient_column+ - specifies the column name you use for storing the content in the database (default: +body+)
      # * +validate_column+ - which column should be validated. Takes the ingredient column if not present
      # * +preview_text_column+ - specifies the column for the preview_text method. (default: ingredient_column)
      # * +preview_text_method+ - a method called on ingredient to get the preview text
      def acts_as_essence(options={})
        configuration = {}
        configuration.update(options) if options.is_a?(Hash)
        ingredient_column = configuration[:ingredient_column].blank? ? 'body' : configuration[:ingredient_column]
        preview_text_column = configuration[:preview_text_column].blank? ? ingredient_column : configuration[:preview_text_column]
        validate_column = configuration[:validate_column].blank? ? ingredient_column : configuration[:validate_column]
        
        class_eval <<-EOV
          include Alchemy::Essence::InstanceMethods
          stampable
          validate :essence_validations, :on => :update
          
          def acts_as_essence_class
            #{self.name}
          end
          
          def validation_column
            '#{validate_column}'
          end
          
          def ingredient_column
            '#{ingredient_column}'
          end
          
          def ingredient
            send('#{ingredient_column}')
          end
          
          def preview_text_column
            '#{preview_text_column}'
          end
          
          def preview_text_method
            '#{configuration[:preview_text_method]}'
          end
          
        EOV
      end
      
    end
    
    module InstanceMethods
      
      # Essence Validations:
      # 
      # Essence validations can be set inside the config/elements.yml file.
      # Currently supported validations are presence_of and uniqueness_of
      # 
      #   - name: artikel
      #     contents:  
      #     - name: headline
      #       type: EssenceText
      #       validate: [presence, uniqueness]
      #
      def essence_validations
        return true if description['validate'].blank?
        description['validate'].each do |validation|
          if validation == 'presence' && body.blank?
            add_essence_error validation_column.to_sym => "blank"
          elsif validation == 'uniqueness' && !acts_as_essence_class.send("find_by_#{ingredient_column}", ingredient).blank?
            add_essence_error validation_column.to_sym => "taken"
          end
        end
      end
      
      def essence_errors
        @essence_errors ||= []
      end
      
      def essence_errors=(errors)
        @essence_errors ||= errors
      end
      
      def add_essence_error(error)
        essence_errors << error
        errors.add(:base, :essence_validation_failed)
      end
      
      # Essence description from config/elements.yml
      def description
        return [] if element.nil?
        element.content_descriptions.detect { |c| c['name'] == self.content.name }
      end
      
      # Returns the Content Essence is in
      def content
        Content.find_by_essence_type_and_essence_id(acts_as_essence_class.to_s, self.id)
      end
      
      # Returns the Element Essence is in
      def element
        return nil if content.nil?
        content.element
      end
      
      # Returns the Page Essence is on
      def page
        return nil if element.nil?
        element.page
      end
      
      # Returns the first x (default 30) characters of ingredient for the Element#preview_text method.
      def preview_text(maxlength = 30)
        if preview_text_method.blank?
          ingredient.to_s[0..maxlength]
        else
          ingredient.send(preview_text_method).to_s[0..maxlength]
        end
      end
      
    end
    
  end
end
