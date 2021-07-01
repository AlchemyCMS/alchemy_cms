# frozen_string_literal: true

module Alchemy
  # Ingredient Validations:
  #
  # Ingredient validations can be set inside the +config/elements.yml+ file.
  #
  # Supported validations are:
  #
  # * presence
  # * uniqueness
  # * format
  #
  # *) format needs to come with a regex or a predefined matcher string as its value.
  #
  # There are already predefined format matchers listed in the +config/alchemy/config.yml+ file.
  # It is also possible to add own format matchers there.
  #
  # Example of format matchers in +config/alchemy/config.yml+:
  #
  # format_matchers:
  #   email: !ruby/regexp '/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/'
  #   url:   !ruby/regexp '/\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix'
  #   ssl:   !ruby/regexp '/https:\/\/[\S]+/'
  #
  # Example of an element definition with ingredient validations:
  #
  #   - name: person
  #     ingredients:
  #     - role: name
  #       type: Text
  #       validate: [presence]
  #     - role: email
  #       type: Text
  #       validate: [format: 'email']
  #     - role: homepage
  #       type: Text
  #       validate: [format: !ruby/regexp '^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$']
  #
  # Example of an element definition with chained validations.
  #
  #   - name: person
  #     ingredients:
  #     - role: name
  #       type: Text
  #       validate: [presence, uniqueness, format: 'name']
  #
  class IngredientValidator < ActiveModel::Validator
    def validate(ingredient)
      @ingredient = ingredient
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

    private

    attr_reader :ingredient

    def validations
      ingredient.definition.fetch(:validate, [])
    end

    def validate_presence(*)
      if ingredient.value.blank?
        ingredient.errors.add(:value, :blank)
      end
    end

    def validate_uniqueness(*)
      if duplicates.any?
        ingredient.errors.add(:value, :taken)
      end
    end

    def validate_format(format)
      matcher = Alchemy::Config.get("format_matchers")[format] || format
      if !ingredient.value.to_s.match?(Regexp.new(matcher))
        ingredient.errors.add(:value, :invalid)
      end
    end

    def duplicates
      ingredient.class
        .joins(:element).merge(Alchemy::Element.available)
        .where(Alchemy::Element.table_name => { name: ingredient.element.name })
        .where(value: ingredient.value)
        .where.not(id: ingredient.id)
    end
  end
end
