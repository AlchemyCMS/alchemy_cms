module Alchemy
	module EssencesHelper

		include Alchemy::ContentsHelper

		# Renders the Content view partial from the passed Element for passed content name.
		# For options see -> render_essence
		def render_essence_view_by_name(element, name, options = {}, html_options = {})
			if element.blank?
				warning('Element is nil')
				return ""
			end
			content = element.content_by_name(name)
			render_essence(content, :view, {:for_view => options}, html_options)
		end

		# Renders the Content partial that is given (:editor, or :view).
		# You can pass several options that are used by the different contents.
		#
		# For the view partial:
		# :image_size => "111x93"                        Used by EssencePicture to render the image via RMagick to that size.
		# :css_class => ""                               This css class gets attached to the content view.
		# :date_format => "Am %d. %m. %Y, um %H:%Mh"     Espacially fot the EssenceDate. See Date.strftime for date formatting.
		# :caption => true                               Pass true to enable that the EssencePicture.caption value gets rendered.
		# :blank_value => ""                             Pass a String that gets rendered if the content.essence is blank.
		#
		# For the editor partial:
		# :css_class => ""                               This css class gets attached to the content editor.
		# :last_image_deletable => false                 Pass true to enable that the last image of an imagecollection (e.g. image gallery) is deletable.
		def render_essence(content, part = :view, options = {}, html_options = {})
			if content.nil?
				return part == :view ? "" : warning('Content is nil', _("content_not_found"))
			elsif content.essence.nil?
				return part == :view ? "" : warning('Essence is nil', _("content_essence_not_found"))
			end
			defaults = {
				:for_editor => {
					:as => 'text_field',
					:css_class => 'long',
					:render_format => "html"
				},
				:for_view => {
					:image_size => "120x90",
					:css_class => "",
					:date_format => "%d. %m. %Y, %H:%Mh",
					:caption => true,
					:blank_value => "",
					:render_format => "html"
				}
			}
			if options["for_#{part}".to_sym].nil?
				options_for_partial = defaults["for_#{part}".to_sym]
			else
				options_for_partial = defaults.fetch("for_#{part}".to_sym).merge(options["for_#{part}".to_sym])
			end
			options = options.merge(defaults)
			render(
				:partial => "alchemy/essences/#{content.essence_partial_name}_#{part.to_s}.#{options_for_partial[:render_format]}.erb",
				:locals => {
					:content => content,
					:options => options_for_partial,
					:html_options => html_options
				}
			)
		end

		# Renders the Content view partial from the given Content.
		# For options see -> render_essence
		def render_essence_view(content, options = {}, html_options = {})
			render_essence(content, :view, {:for_view => options}, html_options)
		end

		# Renders the Content view partial from the given Element for the essence_type (e.g. EssenceRichtext).
		# For multiple contents of same kind inside one element just pass a position so that will be rendered.
		# Otherwise the first content found for this type will be rendered.
		# For options see -> render_essence
		def render_essence_view_by_type(element, type, position = 1, options = {}, html_options = {})
			if element.blank?
				warning('Element is nil')
				return ""
			end
			if position == 1
				content = element.content_by_type(type)
			else
				content = element.contents.find_by_essence_type_and_position(type, position)
			end
			render_essence(content, :view, :for_view => options)
		end

		# Renders the Content view partial from the given Element by position (e.g. 1).
		# For options see -> render_essence
		def render_essence_view_by_position(element, position, options = {}, html_options = {})
			if element.blank?
				warning('Element is nil')
				return ""
			end
			content = element.contents.find_by_position(position)
			render_essence(content, :view, {:for_view => options}, html_options)
		end

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
			return warning('Element is nil', _("no_element_given")) if element.blank?
			return warning('EssenceType is blank', _("No EssenceType given")) if essence_type.blank?
			defaults = {
				:position => 1,
				:all => false
			}
			options = defaults.merge(options)
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
				return warning('Element is nil', _("no_element_given"))
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
