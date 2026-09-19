# frozen_string_literal: true

module Alchemy
  # Preloads related-object associations for a flat collection of elements,
  # using the preloader classes registered in
  # +Alchemy.config.ingredient_preloaders+.
  #
  # This service expects elements that have already been fetched with their
  # +ingredients+ and each ingredient's +related_object+ loaded — for example
  # via +includes(ingredients: :related_object)+. It then fires the secondary
  # preloads (storage blobs, node children, page language, etc.) to make
  # subsequent rendering query-free.
  #
  # The caller is responsible for passing a flat list of *all* elements
  # (including nested ones) so that every ingredient is covered in a single
  # pass without recursion.
  #
  # Related objects are collected per ingredient type so that the correct
  # preloader is called for each type. When multiple ingredient types share
  # the same preloader class (e.g. +File+, +Audio+, and +Video+ all map to
  # +AttachmentPreloader+), the preloader is called exactly once with the
  # deduplicated union of their related objects.
  #
  # @example
  #   all_elements = Element
  #     .where(page_version_id: version.id)
  #     .includes(ingredients: :related_object)
  #   Alchemy::ElementsPreloader.call(all_elements)
  #
  class ElementsPreloader
    # @param elements [Enumerable<Element>]
    def self.call(elements)
      new(elements).call
    end

    # @param elements [Enumerable<Element>]
    def initialize(elements)
      @elements = elements
    end

    def call
      by_preloader = collect_by_preloader
      return if by_preloader.empty?

      by_preloader.each do |preloader_class, related_objects|
        preloader_class.call(related_objects)
      end
    end

    private

    attr_reader :elements

    # Returns a Hash mapping each preloader class to the deduplicated array of
    # related objects it should receive.
    #
    # For each ingredient that has a related_object, the ingredient's class
    # name is looked up in the config map to find the preloader. Related
    # objects are deduplicated by id so that multiple ingredient types sharing
    # a preloader produce a single merged call.
    def collect_by_preloader
      config_map = Alchemy.config.ingredient_preloaders
      # { preloader_class => { related_object.id => related_object } }
      accumulator = Hash.new { |h, k| h[k] = {} }

      elements.each do |element|
        element.ingredients.each do |ingredient|
          obj = ingredient.related_object
          next unless obj

          preloader = config_map[ingredient.class.name]
          next unless preloader

          accumulator[preloader][obj.id] = obj
        end
      end

      accumulator.transform_values(&:values)
    end
  end
end
