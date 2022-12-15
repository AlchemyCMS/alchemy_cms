# frozen_string_literal: true

require "alchemy/upgrader"

module Alchemy::Upgrader::Tasks
  class IngredientsMigrator < Thor
    include Thor::Actions

    no_tasks do
      def create_ingredients(verbose: !Rails.env.test?)
        Alchemy::Deprecation.silence do
          elements_with_ingredients = Alchemy::ElementDefinition.all.select { |d| d.key?(:ingredients) }
          if ENV["ONLY"]
            elements_with_ingredients = elements_with_ingredients.select { |d| d[:name].in? ENV["ONLY"].split(",") }
          end
          # eager load all elements that have ingredients defined but no ingredient records yet.
          all_elements = Alchemy::Element
            .named(elements_with_ingredients.map { |d| d[:name] })
            .preload(contents: :essence)
            .left_outer_joins(:ingredients).where(alchemy_ingredients: { id: nil })
            .to_a
          elements_with_ingredients.map do |element_definition|
            elements = all_elements.select { |e| e.name == element_definition[:name] }
            if elements.any?
              puts "-- Creating ingredients for #{elements.count} #{element_definition[:name]}(s)" if verbose
              elements.each do |element|
                MigrateElementIngredients.call(element)
                print "." if verbose
              end
              puts "\n" if verbose
            elsif verbose
              puts "-- No #{element_definition[:name]} elements found for migration."
            end
          end
        end
      end
    end

    class MigrateElementIngredients
      def self.call(element)
        Alchemy::Element.transaction do
          element.definition[:ingredients].each do |ingredient_definition|
            ingredient = element.ingredients.build(
              role: ingredient_definition[:role],
              type: Alchemy::Ingredient.normalize_type(ingredient_definition[:type]),
            )

            content = element.content_by_name(ingredient_definition[:role])
            if content
              essence = content.essence
              if essence
                belongs_to_associations = essence.class.reflect_on_all_associations(:belongs_to)
                if belongs_to_associations.any?
                  ingredient.related_object = essence.public_send(belongs_to_associations.first.name)
                else
                  ingredient.value = content.ingredient
                end
                data = ingredient.class.stored_attributes.fetch(:data, []).each_with_object({}) do |attr, d|
                  d[attr] = essence.public_send(attr)
                end
                ingredient.data = data
              end
              content.destroy!
            end

            ingredient.save!
          end
        end
      end
    end
  end
end
