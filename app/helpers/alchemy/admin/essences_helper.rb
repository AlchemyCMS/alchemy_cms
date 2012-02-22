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
				return warning('Element is nil', t("no_element_given")) if element.blank?
				return warning('EssenceType is blank', t("No EssenceType given")) if essence_type.blank?
				defaults = {
					:position => 1,
					:all => false
				}
				options = defaults.merge(options)
				essence_type = Alchemy::Content.normalize_essence_type(essence_type)
				return_string = ""
				if options[:all]
					contents = element.contents.find_all_by_essence_type_and_name(essence_type, options[:all])
					contents.each do |content|
						return_string << render_essence_editor(content, editor_options)
					end
				else
					content = element.contents.find_by_essence_type_and_position(essence_type, options[:position])
					return_string = render_essence_editor(content, editor_options)
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
				if content.nil?
					render_missing_content(element, position, options)
				else
					render_essence_editor(content, options)
				end
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
					return warning('Element is nil', t("no_element_given"))
				end
				content = element.content_by_name(name)
				if content.nil?
					render_missing_content(element, name, options)
				else
					render_essence_editor(content, options)
				end
			end

			# Renders the EssenceText editor partial with a form select for storing page urlnames
			# 
			# === Options:
			# 
			#   :only            [Hash]     # Pagelayout names. Only pages with this page_layout will be displayed inside the select.
			#   :page_attribute  [Symbol]   # The Page attribute which will be stored.
			# 
			def page_selector(element, content_name, options = {}, select_options = {})
				default_options = {
					:page_attribute => :id,
					:prompt => t('Choose page')
				}
				options = default_options.merge(options)
				pages = Page.where({
					:language_id => session[:language_id],
					:page_layout => options[:only],
					:public => true
				})
				content = element.content_by_name(content_name)
				options.update(
					:select_values => pages_for_select(pages, content ? content.essence.body : nil, options[:prompt], options[:page_attribute])
				)
				if content.nil?
					render_missing_content(element, content_name, options)
				else
					render_essence_editor(content, options)
				end
			end

			def render_missing_content(element, name, options)
				render :partial => 'alchemy/admin/contents/missing', :locals => {:element => element, :name => name, :options => options}
			end

		end
	end
end
