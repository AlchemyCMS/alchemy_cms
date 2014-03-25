require 'active_record'

module Alchemy #:nodoc:
  module Essence #:nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Delivers various methods we need for Essences in Alchemy.
    #
    # To turn a model into an essence call acts_as_essence inside your model and you will get:
    #   * validations
    #   * several getters (ie: page, element, content, ingredient, preview_text)
    #
    module ClassMethods

      # Turn any active record model into an essence by calling this class method
      #
      # @option options [String || Symbol] ingredient_column ('body')
      #   specifies the column name you use for storing the content in the database (default: +body+)
      # @option options [String || Symbol] validate_column (ingredient_column)
      #   The column the the validations run against.
      # @option options [String || Symbol] preview_text_column (ingredient_column)
      #   Specify the column for the preview_text method.
      #
      def acts_as_essence(options={})
        configuration = {
          ingredient_column: 'body'
        }.update(options)

        class_eval <<-EOV
          attr_writer :validation_errors
          include Alchemy::Essence::InstanceMethods
          stampable stamper_class_name: Alchemy.user_class_name
          validate :validate_ingredient, :on => :update, :if => 'validations.any?'

          has_one :content, :as => :essence
          has_one :element, :through => :content
          has_one :page,    :through => :element

          scope :available,    -> { joins(:element).merge(Element.available) }
          scope :from_element, ->(name) { joins(:element).where(alchemy_elements: { name: name }) }

          delegate :public?, to: :element

          after_update :touch_content

          def acts_as_essence_class
            #{self.name}
          end

          def ingredient_column
            '#{configuration[:ingredient_column]}'
          end

          def validation_column
            '#{configuration[:validate_column] || configuration[:ingredient_column]}'
          end

          def preview_text_column
            '#{configuration[:preview_text_column] || configuration[:ingredient_column]}'
          end
        EOV
      end

    end

    module InstanceMethods

      # Essence Validations:
      #
      # Essence validations can be set inside the config/elements.yml file.
      #
      # Supported validations are:
      #
      # * presence
      # * uniqueness
      # * format
      #
      # format needs to come with a regex or a predefined matcher string as its value.
      # There are already predefined format matchers listed in the config/alchemy/config.yml file.
      # It is also possible to add own format matchers there.
      #
      # Example of format matchers in config/alchemy/config.yml:
      #
      # format_matchers:
      #   email: !ruby/regexp '/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/'
      #   url:   !ruby/regexp '/\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix'
      #   ssl:   !ruby/regexp '/https:\/\/[\S]+/'
      #
      # Example of an element definition with essence validations:
      #
      #   - name: person
      #     contents:
      #     - name: name
      #       type: EssenceText
      #       validate: [presence]
      #     - name: email
      #       type: EssenceText
      #       validate: [format: 'email']
      #     - name: homepage
      #       type: EssenceText
      #       validate: [format: !ruby/regexp '^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$']
      #
      # Example of an element definition with chained validations.
      #
      #   - name: person
      #     contents:
      #     - name: name
      #       type: EssenceText
      #       validate: [presence, uniqueness, format: 'name']
      #
      def validate_ingredient
        validations.each do |validation|
          if validation.respond_to?(:keys)
            validation.map {|key,value| self.send("validate_#{key}", validation) }
          else
            self.send("validate_#{validation}")
          end
        end
      end

      def validations
        @validations ||= description.present? ? description['validate'] || [] : []
      end

      def validation_errors
        @validation_errors ||= []
      end

      def validate_presence
        if ingredient.blank?
          errors.add(ingredient_column, :blank)
          validation_errors << :blank
        end
      end

      def validate_uniqueness
        return if !public?
        if duplicates.any?
          errors.add(ingredient_column, :taken)
          validation_errors << :taken
        end
      end

      def validate_format(validation)
        matcher = Config.get('format_matchers')["#{validation['format']}"] || validation['format']
        if ingredient.to_s.match(Regexp.new(matcher)).nil?
          errors.add(ingredient_column, :invalid)
          validation_errors << :invalid
        end
      end

      def duplicates
        acts_as_essence_class
          .available
          .from_element(element.name)
          .where("#{ingredient_column}" => ingredient)
          .where.not(id: self.id)
      end

      # Returns the value stored from the database column that is configured as ingredient column.
      def ingredient
        if self.respond_to?(ingredient_column)
          self.send(ingredient_column)
        end
      end

      # Returns the value stored from the database column that is configured as ingredient column.
      def ingredient=(value)
        if self.respond_to?(ingredient_setter_method)
          self.send(ingredient_setter_method, value)
        end
      end

      # Returns the setter method for ingredient column
      def ingredient_setter_method
        ingredient_column.to_s + '='
      end

      # Essence description from config/elements.yml
      def description
        return {} if element.nil? or element.content_descriptions.nil?
        element.content_descriptions.detect { |c| c['name'] == self.content.name } || {}
      end

      # Touch content. Called after update.
      def touch_content
        return nil if content.nil?
        content.touch
      end

      # Returns the first x (default 30) characters of ingredient for the Element#preview_text method.
      #
      def preview_text(maxlength = 30)
        self.send(preview_text_column).to_s[0..maxlength-1]
      end

      def open_link_in_new_window?
        respond_to?(:link_target) && link_target == 'blank'
      end

      def partial_name
        self.class.name.split('::').last.underscore
      end

      def acts_as_essence?
        acts_as_essence_class.present?
      end

      def to_partial_path
        "alchemy/essences/#{partial_name}_view"
      end

    end

  end
end
ActiveRecord::Base.class_eval { include Alchemy::Essence } if defined?(Alchemy::Essence)
