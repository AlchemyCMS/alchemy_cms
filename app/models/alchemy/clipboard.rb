module Alchemy

  # The Clipboard holds element ids and page ids
  #
  # It is stored inside the session.
  #
  # Each entry can has an action keyword that describes what to do after pasting the item.
  #
  # The keyword can be one of 'copy' or 'cut'
  class Clipboard

    attr_accessor :items

    def initialize(items)
      @items = items.is_a?(Hash) ? items.with_indifferent_access : self.class.empty_clipboard
    end

    # Returns all items of the collection from category (+:elements+ or +:pages+)
    def all(item_type)
      @items.fetch(item_type.to_sym)
    end
    alias_method :[], :all

    # Returns the item from collection of category (+:elements+ or +:pages+)
    def get(item_type, item_id)
      all(item_type).detect { |item| item[:id].to_i == item_id.to_i }
    end

    # Returns true if the id is already in the collection of category (+:elements+ or +:pages+)
    def contains?(item_type, item_id)
      all(item_type).collect { |item| item[:id].to_i }.include?(item_id.to_i)
    end

    # Insert an item into the collection of category (+:elements+ or +:pages+)
    def push(item_type, item)
      all(item_type).push(normalized(item))
    end

    def replace(item_type, item)
      all(item_type).replace(item.is_a?(Array) ? item : [item])
    end
    alias_method :[]=, :replace

    def remove(item_type, item_id)
      all(item_type).delete_if { |item| item[:id].to_i == item_id.to_i }
    end

    def clear(item_type = nil)
      if item_type
        all(item_type).clear
      else
        @items = self.class.empty_clipboard
      end
    end

    def empty?
      @items == self.class.empty_clipboard
    end

  private

    def normalized(item)
      item[:id] = item[:id].to_i
      item
    end

  protected

    def self.empty_clipboard
      {:elements => [], :pages => []}
    end

  end
end
