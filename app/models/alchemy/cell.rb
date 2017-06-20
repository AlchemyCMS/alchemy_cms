# == Schema Information
#
# Table name: alchemy_cells
#
#  id         :integer          not null, primary key
#  page_id    :integer
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# A cell is a group of elements that are rendered inside a specific area on your page_layout.
# Think of it like a column, or section in your layout. I.e. a header or right column.
#
# Elements are displayed in tabs inside the elements window in page edit view.
# Every cell is a list of elements with the position scoped to +cell_id+ and +page_id+.
#
# Define cells inside a +cells.yml+ file located in the +config/alchemy+ folder of your project.
#
# Render cells with the +render_cell+ helper
#
# Views for cells are inside the +app/views/cells+ folder in your project.
#
module Alchemy
  class Cell < ActiveRecord::Base
    include Alchemy::Logger

    belongs_to :page, required: true
    validates_uniqueness_of :name, scope: 'page_id'
    validates_format_of :name, with: /\A[a-z0-9_-]+\z/
    has_many :elements, -> { where(parent_element_id: nil).order(:position) }, dependent: :destroy

    class << self
      def definitions
        @definitions ||= read_yml_file
      end

      def definition_for(cellname)
        return nil if cellname.blank?
        definitions.detect { |c| c['name'] == cellname }
      end

      def all_definitions_for(cellnames)
        definitions.select { |c| cellnames.include? c['name'] }
      end

      def definitions_for_element(element_name)
        return [] if definitions.blank?
        definitions.select { |d| d['elements'].include?(element_name) }
      end

      def translated_label_for(cell_name)
        Alchemy.t(cell_name, scope: 'cell_names', default: cell_name.to_s.humanize)
      end

      private

      def read_yml_file
        ::YAML.safe_load(ERB.new(File.read(yml_file_path)).result, [], [], true) || []
      end

      def yml_file_path
        Rails.root.join('config', 'alchemy', 'cells.yml')
      end
    end

    def to_partial_path
      "alchemy/cells/#{name}"
    end

    # Returns the cell definition defined in +config/alchemy/cells.yml+
    #
    def definition
      definition = self.class.definition_for(name)
      if definition.blank?
        log_warning "Could not find cell definition for #{name}. Please check your cells.yml!"
        return {}
      else
        definition
      end
    end

    # Returns all elements that can be placed in this cell
    def element_definitions
      definition['elements'] || []
    end
    alias_method :available_elements, :element_definitions

    def name_for_label
      self.class.translated_label_for(name)
    end
  end
end
