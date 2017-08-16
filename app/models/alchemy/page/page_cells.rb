# frozen_string_literal: true

module Alchemy
  module Page::PageCells
    extend ActiveSupport::Concern

    included do
      has_many :cells, dependent: :destroy
      after_create :create_cells, if: :can_have_cells?, unless: :systempage?
    end

    module ClassMethods
      # Copy page cells
      #
      # @param source [Alchemy::Page]
      # @param target [Alchemy::Page]
      # @return [Array]
      #
      def copy_cells(source, target)
        new_cells = []
        source.cells.each do |cell|
          new_cells << Cell.create(name: cell.name, page_id: target.id)
        end
        new_cells
      end
    end

    # Returns true, if the page's definition defines cells.
    def can_have_cells?
      definition['cells'].present?
    end

    # Returns true, if the page has cells.
    def has_cells?
      cells.any?
    end

    # Returns the cell definitions from page definition.
    def cell_definitions
      cell_names = definition['cells']
      return [] if cell_names.blank?
      Cell.all_definitions_for(cell_names)
    end

    # Returns elements grouped by cell.
    def elements_grouped_by_cells
      elements.not_trashed.in_cell.group_by(&:cell)
    end

    # Returns element names from cell definition.
    def element_names_from_cells
      cell_definitions.collect { |c| c['elements'] }.flatten.uniq
    end

    # Returns element names that are not defined in a cell.
    def element_names_not_in_cell
      definition['elements'].uniq - element_names_from_cells
    end

    private

    # Creates cells that are defined in page's page_layout definition.
    def create_cells
      definition['cells'].each do |cellname|
        cells.create!(name: cellname)
      end
    end
  end
end
