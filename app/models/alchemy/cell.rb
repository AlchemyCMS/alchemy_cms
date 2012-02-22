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

		belongs_to :page
		validates_uniqueness_of :name, :scope => :page_id
		has_many :elements, :dependent => :destroy, :order => :position

		def self.definitions
			cell_yml = ::File.join(::Rails.root, 'config', 'alchemy', 'cells.yml')
			::YAML.load_file(cell_yml) if ::File.exist?(cell_yml)
		end

		def self.definition_for(cellname)
			return nil if cellname.blank?
			definitions.detect { |c| c['name'] == cellname }
		end

		def self.all_definitions_for(cellnames)
			definitions.select { |c| cellnames.include? c['name'] }
		end

		def self.all_element_definitions_for(cellnames)
			element_names = []
			all_definitions_for(cellnames).each do |cell|
				element_names += cell['elements']
			end
			Element.all_definitions_for(element_names.uniq)
		end

		def self.definitions_for_element(element_name)
			return [] if definitions.blank?
			definitions.select { |d| d['elements'].include?(element_name) }
		end

		def self.names_for_element(element_name)
			definitions = definitions_for_element(element_name)
			return nil if definitions.blank?
			definitions.collect { |d| d['name'] }
		end

		def name_for_label
			self.class.translated_label_for(self.name)
		end

		def self.translated_label_for(cell_name)
			I18n.t(cell_name, :scope => :cell_names)
		end
  
	end
end
