module Alchemy
	module Admin
		module ElementsHelper

			include Alchemy::ElementsHelper
			include Alchemy::Admin::BaseHelper
			include Alchemy::Admin::ContentsHelper
			include Alchemy::Admin::EssencesHelper

			# Returns an Array for essence_text_editor select options_for_select.
			def elements_by_name_for_select(name, options={})
				defaults = {
					:grouped_by_page => true,
					:from_page => :all
				}
				options = defaults.merge(options)
				elements = all_elements_by_name(
					name,
					:from_page => options[:from_page]
				)
				if options[:grouped_by_page] && options[:from_page] == :all
					elements_for_options = {}
					pages = elements.collect(&:page).compact.uniq
					pages.sort{ |x,y| x.name <=> y.name }.each do |page|
						page_elements = page.elements.select { |e| e.name == name }
						elements_for_options[page.name] = page_elements.map { |pe| [pe.preview_text, pe.id.to_s] }
					end
				else
					elements_for_options = elements.map { |e| [e.preview_text, e.id.to_s] }
					elements_for_options = [''] + elements_for_options
				end
				return elements_for_options
			end

			# Renders the element editor partial
			def render_editor(element)
				render_element(element, :editor)
			end

			# This helper renderes the picture editor for the elements on the Alchemy Desktop.
			# It brings full functionality for adding images to the element, deleting images from it and sorting them via drag'n'drop.
			# Just place this helper inside your element editor view, pass the element as parameter and that's it.
			#
			# Options:
			# :maximum_amount_of_images (integer), default nil. This option let you handle the amount of images your customer can add to this element.
			def render_picture_editor(element, options={})
				default_options = {
					:last_image_deletable => true,
					:maximum_amount_of_images => nil,
					:refresh_sortable => true
				}
				options = default_options.merge(options)
				picture_contents = element.all_contents_by_type("Alchemy::EssencePicture")
				render(
					:partial => "alchemy/admin/elements/picture_editor",
					:locals => {
						:picture_contents => picture_contents,
						:element => element,
						:options => options
					}
				)
			end

			# Returns all elements that could be placed on that page because of the pages layout.
			# The elements are returned as an array to be used in alchemy_selectbox form builder.
			def elements_for_select(elements)
				return [] if elements.nil?
				options = elements.collect{ |e| [t("element_names.#{e['name']}", :default => e['name'].capitalize), e["name"]] }
				return options_for_select(options)
			end

			# Returns all elements that could be placed on that page because of the pages layout.
			# The elements will be grouped by cell.
			def grouped_elements_for_select(elements, object_method = 'name')
				return "" if elements.blank?
				cells_definition = @page.cell_definitions
				return "" if cells_definition.blank?
				options = {}
				celled_elements = []
				cells_definition.each do |cell|
					cell_elements = elements.select { |e| cell['elements'].include?(e.class.name == 'Element' ? e.name : e['name']) }
					celled_elements += cell_elements
					optgroup_label = Cell.translated_label_for(cell['name'])
					options[optgroup_label] = cell_elements.map do |e|
						element_array_for_options(e, object_method, cell)
					end
				end
				other_elements = elements - celled_elements
				unless other_elements.blank?
					optgroup_label = t('other Elements')
					options[optgroup_label] = other_elements.map do |e|
						element_array_for_options(e, object_method)
					end
				end
				return grouped_options_for_select(options)
			end

			def element_array_for_options(e, object_method, cell = nil)
				if e.class.name == 'Element'
					[
						e.display_name_with_preview_text,
						e.send(object_method).to_s + (cell ? "##{cell['name']}" : "")
					]
				else
					[
						t("alchemy.element_names.#{e['name']}", :default => e['name'].capitalize),
						e[object_method] + (cell ? "##{cell['name']}" : "")
					]
				end
			end

		end
	end
end
