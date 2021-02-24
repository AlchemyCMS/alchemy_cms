# frozen_string_literal: true

module Alchemy
  # Mimics ActiveRecord query interface
  # but does this on the preloaded elements
  class ElementsRepository
    include Enumerable

    # An empty set of elements
    def self.none
      new([])
    end

    # @param [ActiveRecord::Relation]
    def initialize(elements)
      @elements = elements.to_a
    end

    # All visible elements
    # @return [Alchemy::ElementRepository]
    def visible
      self.class.new select(&:public)
    end

    # All not fixed elements
    # @return [Alchemy::ElementRepository]
    def hidden
      self.class.new reject(&:public)
    end

    # All elements with given name(s)
    # @param [Array<String|Symbol>|String|Symbol]
    # @return [Alchemy::ElementRepository]
    def named(*names)
      names.flatten!
      self.class.new(select { |e| e.name.in?(names.map!(&:to_s)) })
    end

    # Filter elements by given attribute and value
    # @param [Array|Hash]
    # @return [Alchemy::ElementRepository]
    def where(attrs)
      self.class.new(
        select do |element|
          attrs.all? do |attr, value|
            element.public_send(attr) == value
          end
        end
      )
    end

    # All elements excluding those wth given name(s)
    # @param [Array<String|Symbol>|String|Symbol]
    # @return [Alchemy::ElementRepository]
    def excluded(*names)
      names.flatten!
      self.class.new(reject { |e| e.name.in?(names.map!(&:to_s)) })
    end

    # All fixed elements
    # @return [Alchemy::ElementRepository]
    def fixed
      self.class.new select(&:fixed)
    end

    # All not fixed elements
    # @return [Alchemy::ElementRepository]
    def unfixed
      self.class.new reject(&:fixed)
    end

    # All folded elements
    # @return [Alchemy::ElementRepository]
    def folded
      self.class.new select(&:folded)
    end

    # All expanded elements
    # @return [Alchemy::ElementRepository]
    def expanded
      self.class.new reject(&:folded)
    end

    # All not nested top level elements
    # @return [Alchemy::ElementRepository]
    def not_nested
      self.class.new(select { |e| e.parent_element_id.nil? })
    end

    # Elements in reversed order
    # @return [Alchemy::ElementRepository]
    def reverse
      self.class.new elements.reverse
    end

    # Elements in random order
    # @return [Alchemy::ElementRepository]
    def random
      self.class.new Array(elements).shuffle
    end

    # Elements off setted by
    # @return [Alchemy::ElementRepository]
    def offset(offset)
      self.class.new elements[offset.to_i..-1]
    end

    # Elements limitted by
    # @return [Alchemy::ElementRepository]
    def limit(limit)
      self.class.new elements[0..(limit.to_i - 1)]
    end

    def each(&blk)
      elements.each(&blk)
    end

    private

    attr_reader :elements
  end
end
