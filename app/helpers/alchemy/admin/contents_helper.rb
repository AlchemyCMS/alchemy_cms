module Alchemy
	module Admin
		module ContentsHelper

			include Alchemy::Admin::BaseHelper

			# Returns a string for the id attribute of a html element for the given content
			def content_dom_id(content)
				return "" if content.nil?
				if content.class == String
					c = Content.find_by_name(content)
					return "" if c.nil?
				else
					c = content
				end
				"#{c.essence_type.demodulize.underscore}_#{c.id}"
			end

			# Renders the name of elements content or the default name defined in elements.yml
			def render_content_name(content)
				if content.blank?
					warning('Element is nil')
					return ""
				else
					content_name = content.name_for_label
				end
				if content.description.blank?
					warning("Content #{content.name} is missing its description")
					title = t("Warning: Content is missing its description.", :contentname => content.name)
					content_name = %(<span class="warning icon" title="#{title}"></span>&nbsp;) + content_name.html_safe
				end
				content.has_validations? ? "#{content_name}<span class='validation_indicator'>*</span>".html_safe : content_name
			end

			# Renders a link to show the new content overlay
			def render_new_content_link(element)
				link_to_overlay_window(
					t('add new content'),
					alchemy.new_admin_element_content_path(element),
					{
						:size => '305x40',
						:title => t('Select an content'),
						:overflow => true
					},
					{
						:id => "add_content_for_element_#{element.id}",
						:class => 'button new_content_link'
					}
				)
			end

			# Renders a link to create a new content in element editor
			def render_create_content_link(element, options = {})
				defaults = {
					:label => t('add new content')
				}
				options = defaults.merge(options)
				link_to(
					options[:label],
					alchemy.admin_contents_path(
						:content => {
							:name => options[:content_name],
							:element_id => element.id
						}
					),
					:method => 'post',
					:remote => true,
					:id => "add_content_for_element_#{element.id}",
					:class => 'button new_content_link'
				)
			end

			# Returns a textarea ready to use with tinymce
			def tinymce_tag(name, content = '', options = {})
				append_class_name(options, 'tinymce')
				text_area_tag(name, content, options)
			end

		end
	end
end
