module Alchemy
	module Admin
		module EssencesHelper

			include Alchemy::EssencesHelper
			include Alchemy::Admin::ContentsHelper

			# Renders the Content editor partial from the given Content.
			# For options see -> render_essence
			def render_essence_editor(content, options = {})
				render_essence(content, :editor, :for_editor => options)
			end

			# Renders the Content editor partial from essence_type.
			# 
			# Options are:
			#   * element (Element) - the Element the contents are in (obligatory)
			#   * type (String) - the type of Essence (obligatory)
			#   * options (Hash):
			#   ** :position (Integer) - The position of the Content inside the Element. I.E. for getting the n-th EssencePicture. Default is 1 (the first)
			#   ** :all (String) - Pass :all to get all Contents of that name. Default false
			#   * editor_options (Hash) - Will be passed to the render_essence_editor partial renderer
			#
			def render_essence_editor_by_type(element, essence_type, options = {}, editor_options = {})
				return warning('Element is nil', t("no_element_given", :scope => :alchemy)) if element.blank?
				return warning('EssenceType is blank', t("No EssenceType given", :scope => :alchemy)) if essence_type.blank?
				defaults = {
					:position => 1,
					:all => false
				}
				options = defaults.merge(options)
				essence_type = normalized_essence_type(essence_type)
				return_string = ""
				if options[:all]
					contents = element.contents.find_all_by_essence_type_and_name(essence_type, options[:all])
					contents.each do |content|
						return_string << render_essence(content, :editor, :for_editor => editor_options)
					end
				else
					content = element.contents.find_by_essence_type_and_position(essence_type, options[:position])
					return_string = render_essence(content, :editor, :for_editor => editor_options)
				end
				return_string
			end

			# Renders the Content editor partial from the given Element by position (e.g. 1).
			# For options see -> render_essence
			def render_essence_editor_by_position(element, position, options = {})
				if element.blank?
					warning('Element is nil')
					return ""
				end
				content = element.contents.find_by_position(position)
				render_essence(content, :editor, :for_editor => options)
			end

			# Renders the Content editor partial found in views/contents/ for the content with name inside the passed Element.
			# For options see -> render_essence
			# 
			# Content creation on the fly:
			# 
			# If you update the elements.yml file after creating an element this helper displays a error message with an option to create the content.
			#
			def render_essence_editor_by_name(element, name, options = {})
				if element.blank?
					return warning('Element is nil', t("no_element_given", :scope => :alchemy))
				end
				content = element.content_by_name(name)
				if content.blank?
					render :partial => 'alchemy/admin/contents/missing', :locals => {:element => element, :name => name}
				else
					render_essence(content, :editor, :for_editor => options)
				end
			end

		end
	end
end
