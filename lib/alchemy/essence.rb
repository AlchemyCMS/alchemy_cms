# frozen_string_literal: true

require "active_record"

module Alchemy #:nodoc:
  # A bogus association that skips eager loading for essences not having an ingredient association
  class IngredientAssociation < ActiveRecord::Associations::BelongsToAssociation
    # Skip eager loading if called by Rails' preloader
    def klass
      if caller.any? { |line| line =~ /preloader\.rb/ }
        nil
      else
        super
      end
    end
  end

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
      def acts_as_essence(options = {})
        register_as_essence_association!

        configuration = {
          ingredient_column: "body",
        }.update(options)

        @_classes_with_ingredient_association ||= []

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          attr_writer :validation_errors
          include Alchemy::Essence::InstanceMethods

          validate :validate_ingredient, on: :update, if: -> { validations.any? }

          has_one :content, as: :essence, class_name: "Alchemy::Content", inverse_of: :essence
          has_one :element, through: :content, class_name: "Alchemy::Element"
          has_one :page,    through: :element, class_name: "Alchemy::Page"

          scope :available,    -> { joins(:element).merge(Alchemy::Element.available) }
          scope :from_element, ->(name) { joins(:element).where(Element.table_name => { name: name }) }

          delegate :restricted?, to: :page,    allow_nil: true
          delegate :public?,     to: :element, allow_nil: true

          after_save :touch_element

          def acts_as_essence_class
            #{name}
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
        RUBY

        if configuration[:belongs_to]
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            belongs_to :ingredient_association, **#{configuration[:belongs_to]}

            alias_method :#{configuration[:ingredient_column]}, :ingredient_association
            alias_method :#{configuration[:ingredient_column]}=, :ingredient_association=
          RUBY

          @_classes_with_ingredient_association << self
        end
      end

      # Overwrite ActiveRecords method to return a bogus association class that skips eager loading
      # for essence classes that do not have an ingredient association
      def _reflect_on_association(name)
        if name == :ingredient_association && !in?(@_classes_with_ingredient_association)
          OpenStruct.new(association_class: Alchemy::IngredientAssociation)
        else
          super
        end
      end

      private

      # Register the current class as has_many association on +Alchemy::Page+ and +Alchemy::Element+ models
      def register_as_essence_association!
        klass_name = model_name.to_s
        arguments = [:has_many, klass_name.demodulize.tableize.to_sym]
        kwargs = { through: :contents, source: :essence, source_type: klass_name }
        %w(Page Element).each { |k| "Alchemy::#{k}".constantize.send(*arguments, **kwargs) }
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
            validation.map do |key, value|
              send("validate_#{key}", value)
            end
          else
            send("validate_#{validation}")
          end
        end
      end

      def validations
        @validations ||= definition.present? ? definition["validate"] || [] : []
      end

      def validation_errors
        @validation_errors ||= []
      end

      def validate_presence(validate = true)
        if validate && ingredient.blank?
          errors.add(ingredient_column, :blank)
          validation_errors << :blank
        end
      end

      def validate_uniqueness(validate = true)
        return if !validate || !public?

        if duplicates.any?
          errors.add(ingredient_column, :taken)
          validation_errors << :taken
        end
      end

      def validate_format(format)
        matcher = Config.get("format_matchers")[format] || format
        if ingredient.to_s.match(Regexp.new(matcher)).nil?
          errors.add(ingredient_column, :invalid)
          validation_errors << :invalid
        end
      end

      def duplicates
        acts_as_essence_class
          .available
          .from_element(element.name)
          .where(ingredient_column.to_s => ingredient)
          .where.not(id: id)
      end

      # Returns the value stored from the database column that is configured as ingredient column.
      def ingredient
        if respond_to?(ingredient_column)
          send(ingredient_column)
        end
      end

      # Sets the value stored in the database column that is configured as ingredient column.
      def ingredient=(value)
        if respond_to?(ingredient_setter_method)
          send(ingredient_setter_method, value)
        end
      end

      # Returns the setter method for ingredient column
      def ingredient_setter_method
        ingredient_column.to_s + "="
      end

      # Essence definition from config/elements.yml
      def definition
        return {} if element.nil? || element.content_definitions.nil?

        element.content_definitions.detect { |c| c["name"] == content.name } || {}
      end

      # Touches element. Called after save.
      def touch_element
        element&.touch
      end

      # Returns the first x (default 30) characters of ingredient for the Element#preview_text method.
      #
      def preview_text(maxlength = 30)
        send(preview_text_column).to_s[0..maxlength - 1]
      end

      def open_link_in_new_window?
        respond_to?(:link_target) && link_target == "blank"
      end

      def partial_name
        self.class.name.split("::").last.underscore
      end

      def acts_as_essence?
        acts_as_essence_class.present?
      end

      def to_partial_path
        "alchemy/essences/#{partial_name}_view"
      end

      def has_tinymce?
        false
      end
    end
  end
end

ActiveRecord::Base.include(Alchemy::Essence)
