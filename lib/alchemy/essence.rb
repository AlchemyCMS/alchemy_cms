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
          attr_accessor :validation_errors
          include Alchemy::Essence::InstanceMethods
          stampable stamper_class_name: Alchemy.user_class_name
          validate :essence_validations, :on => :update
          has_many :contents, :as => :essence
          has_many :elements, :through => :contents
          has_many :pages, :through => :elements

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
      # Currently supported validations are:
      #
      # * presence
      # * format
      # * uniqueness
      #
      # If you want to validate the format you must additionally pass validate_format_as or validate_format_with:
      #
      # * validate_format_with has to be regex
      # * validate_format_as can be one of:
      # ** url
      # ** email
      #
      # Example:
      #
      #   - name: person
      #     contents:
      #     - name: name
      #       type: EssenceText
      #       validate: [presence]
      #     - name: email
      #       type: EssenceText
      #       validate: [format]
      #       validate_format_as: 'email'
      #     - name: homepage
      #       type: EssenceText
      #       validate: [format]
      #       validate_format_with: '^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$'
      #
      def essence_validations
        self.validation_errors ||= []
        return true if description.blank? || description['validate'].blank?
        description['validate'].each do |validation|
          if validation == 'presence' && ingredient.blank?
            self.validation_errors << :blank
          elsif validation == 'format'
            if description['validate_format_as'].blank? && !description['validate_format_with'].blank?
              matcher = Regexp.new(description['validate_format_with'])
            elsif !description['validate_format_as'].blank? && description['validate_format_with'].blank?
              case description['validate_format_as']
              when 'email'
              then
                matcher = Alchemy::Config.get(:email_regexp)
              when 'url'
              then
                matcher = /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
              else
                raise "No validation format matcher found for #{description['validate_format_as']}"
              end
            else
              raise 'No validation format matcher given'
            end
            if ingredient.to_s.match(matcher).nil?
              self.validation_errors << :invalid
            end
          elsif validation == 'uniqueness' && acts_as_essence_class.where("#{ingredient_column}" => ingredient).where.not(id: self.id).any?
            self.validation_errors << :taken
          end
        end
        self.validation_errors.each do |validation_error|
          self.errors.add(self.ingredient_column, validation_error)
        end
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

      # Returns the Content Essence is in
      def content
        @content ||= Alchemy::Content.find_by(essence_type: acts_as_essence_class.to_s, essence_id: self.id)
      end

      # Touch content. Called after update.
      def touch_content
        return nil if content.nil?
        content.touch
      end

      # Returns the Element Essence is in
      def element
        return nil if content.nil?
        @element ||= content.element
      end

      # Returns the Page Essence is on
      def page
        return nil if element.nil?
        @page ||= element.page
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
        !acts_as_essence_class.blank?
      end

      def to_partial_path
        "alchemy/essences/#{partial_name}_view"
      end

    end

  end
end
ActiveRecord::Base.class_eval { include Alchemy::Essence } if defined?(Alchemy::Essence)
