# frozen_string_literal: true

module Alchemy
  # Mimics ActiveRecord query interface
  # but does this on the preloaded elements
  class ElementsRepository
    include Enumerable

    # @param [ActiveRecord::Relation]
    def initialize(elements)
      @elements = elements.to_a
    end

    # All visible elements
    # @return [Array]
    def visible
      select(&:public)
    end

    # All not fixed elements
    # @return [Array]
    def hidden
      reject(&:public)
    end

    # All elements with given name(s)
    # @param [Array<String|Symbol>|String|Symbol]
    # @return [Array]
    def named(*names)
      names.flatten!
      select { |e| e.name.in?(names.map!(&:to_s)) }
    end

    # Filter elements by given attribute and value
    # @param [Array|Hash]
    # @return [Array]
    def where(attrs)
      select do |element|
        attrs.all? do |attr, value|
          element.public_send(attr) == value
        end
      end
    end

    # All elements excluding those wth given name(s)
    # @param [Array<String|Symbol>|String|Symbol]
    # @return [Array]
    def excluded(*names)
      names.flatten!
      reject { |e| e.name.in?(names.map!(&:to_s)) }
    end

    # All fixed elements
    # @return [Array]
    def fixed
      select(&:fixed)
    end

    # All not fixed elements
    # @return [Array]
    def unfixed
      reject(&:fixed)
    end

    # All folded elements
    # @return [Array]
    def folded
      select(&:folded)
    end

    # All expanded elements
    # @return [Array]
    def expanded
      reject(&:folded)
    end

    def each(&blk)
      elements.each(&blk)
    end

    private

    attr_reader :elements
  end
end
