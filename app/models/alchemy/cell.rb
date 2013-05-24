# A cell is a group of elements that are rendered inside a specific area on your page_layout.
# Think of it like a column, or section in your layout. I.e. a header or right column.
#
# Elements are displayed in tabs inside the elements window in page edit view.
# Every cell is a list of elements with the position scoped to +cell_id+ and +page_id+.
#
# Define cells inside a +cells.yml+ file located in the +config/alchermy+ folder of your project.
#
# Render cells with the +render_cell+ helper
#
# Views for cells are inside the +app/views/cells+ folder in you project.
#
module Alchemy
  class Cell < ActiveRecord::Base
    include Logger

    attr_accessible :page_id, :name

    belongs_to :page
    validates_uniqueness_of :name, :scope => :page_id
    has_many :elements, :dependent => :destroy, :order => :position

    def self.definitions
      cell_yml = ::File.join(::Rails.root, 'config', 'alchemy', 'cells.yml')
      ::YAML.load_file(cell_yml)
    end

    def self.definition_for(cellname)
      return nil if cellname.blank?
      definitions.detect { |c| c['name'] == cellname }
    end

    def self.all_definitions_for(cellnames)
      definitions.select { |c| cellnames.include? c['name'] }
    end

    def self.definitions_for_element(element_name)
      return [] if definitions.blank?
      definitions.select { |d| d['elements'].include?(element_name) }
    end

    def self.translated_label_for(cell_name)
      I18n.t(cell_name, scope: 'cell_names', default: cell_name.to_s.humanize)
    end

    # Returns the cell definition defined in +config/alchemy/cells.yml+
    def description
      description = self.class.definition_for(self.name)
      if description.blank?
        log_warning "Could not find cell definition for #{self.name}. Please check your cells.yml!"
        return {}
      else
        description
      end
    end
    alias_method :definition, :description

    # Returns all elements that can be placed in this cell
    def available_elements
      description['elements'] || []
    end

    def name_for_label
      self.class.translated_label_for(self.name)
    end

  end
end
