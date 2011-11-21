module Alchemy
	module BaseHelper

		include FastGettext::Translation

		# An alias for truncate.
		# Left here for downwards compatibilty.
		def shorten(text, length)
			text.truncate(:length => length)
		end

		# This helper renders the link for an overlay window.
		# We use this for our fancy modal overlay windows in the Alchemy cockpit.
		# 
		# Options:
		# 
		#   :size             [String]              # String with format of "WidthxHeight". I.E. ("420x280")
		#   :title            [String]              # Text for the overlay title bar.
		#   :overflow         [Boolean]             # Should the dialog have overlapping content. If not, it shows scrollbars. Good for select boxes. Default false.
		#   :resizable        [Boolean]             # Is the dialog window resizable? Default false.
		#   :modal            [Boolean]             # Show as modal window. Default true.
		# 
		def link_to_overlay_window(content, url, options={}, html_options={})
			default_options = {
				:modal => true,
				:overflow => false,
				:resizable => false
			}
			options = default_options.merge(options)
			link_to_function(
				content,
				"Alchemy.openWindow(
					\'#{url}\',
					\'#{options[:title]}\',
					\'#{options[:size] ? options[:size].split('x')[0].to_s : 'auto'}\',
					\'#{options[:size] ? options[:size].split('x')[1].to_s : 'auto'}\',
					#{options[:resizable]},
					#{options[:modal]},
					#{options[:overflow]}
				)",
				html_options
			)
		end

		# Used for rendering the folder link in Admin::Pages.index sitemap.
		def sitemapFolderLink(page)
			return '' if page.level == 1
			if page.folded?(current_user.id)
				css_class = 'folded'
				title = _('Show childpages')
			else
				css_class = 'collapsed'
				title = _('Hide childpages')
			end
			link_to(
				'',
				fold_admin_page_path(page),
				:remote => true,
				:method => :post,
				:class => "page_folder #{css_class}",
				:title => title,
				:id => "fold_button_#{page.id}"
			)
		end

		# Returns @current_language set in the action (e.g. Page.show)
		def current_language
			if @current_language.nil?
				warning('@current_language is not set')
				return nil
			else
				@current_language
			end
		end

		# Used for language selector in Alchemy cockpit sitemap. So the user can select the language branche of the page.
		def language_codes_for_select
			configuration(:languages).collect{ |language|
				language[:language_code]
			}
		end

		# Used for translations selector in Alchemy cockpit user settings.
		def translations_for_select
			configuration(:translations).collect{ |translation|
				[translation[:language], translation[:language_code]]
			}
		end

		# Used by Alchemy to display a javascript driven filter for lists in the Alchemy cockpit.
		def js_filter_field options = {}
			default_options = {
				:class => "thin_border js_filter_field",
				:onkeyup => "Alchemy.ListFilter('#contact_list li')",
				:id => "search_field"
			}
			options = default_options.merge(options)
			options[:onkeyup] << ";jQuery('#search_field').val().length >= 1 ? jQuery('.js_filter_field_clear').show() : jQuery('.js_filter_field_clear').hide();"
			filter_field = "<div class=\"js_filter_field_box\">"
			filter_field << text_field_tag("filter", '', options)
			filter_field << content_tag('span', '', :class => 'icon search')
			filter_field << link_to_function(
				"",
				"jQuery('##{options[:id]}').val('');#{options[:onkeyup]}",
				:class => "js_filter_field_clear",
				:style => "display:none",
				:title => _("click_to_show_all")
			)
			filter_field << "<label for=\"search_field\">" + _("search") + "</label>"
			filter_field << "</div>"
			filter_field.html_safe
		end

		def link_to_confirmation_window(link_string = "", message = "", url = "", html_options = {})
			title = _("please_confirm")
			ok_lable = _("yes")
			cancel_lable = _("no")
			link_to_function(
				link_string,
				"Alchemy.confirmToDeleteWindow('#{url}', '#{title}', '#{message}', '#{ok_lable}', '#{cancel_lable}');",
				html_options
			)
		end

		# Renders a form select tag for storing page urlnames
		# Options:
		#   * element - element the Content find via content_name to store the pages urlname in.
		#   * content_name - the name of the content from element to store the pages urlname in.
		#   * options (Hash)
		#   ** :only (Hash)  - pass page_layout names to :page_layout => [""] so only pages with this page_layout will be displayed inside the select.
		#   ** :except (Hash)  - pass page_layout names to :page_layout => [""] so all pages except these with this page_layout will be displayed inside the select.
		#   ** :page_attribute (Symbol) - The Page attribute which will be stored.
		#   * select_options (Hash) - will be passed to the select_tag helper
		def page_selector(element, content_name, options = {}, select_options = {})
			default_options = {
				:except => {
					:page_layout => [""]
				},
				:only => {
					:page_layout => [""]
				},
				:page_attribute => :urlname,
				:prompt => _('Choose page')
			}
			options = default_options.merge(options)
			content = element.content_by_name(content_name)
			if content.nil?
				return warning('Content', _('content_not_found'))
			elsif content.essence.nil?
				return warning('Content', _('content_essence_not_found'))
			end
			pages = Page.where({
				:language_id => session[:language_id],
				:page_layout => options[:only][:page_layout],
				:public => true
			})
			select_tag(
				"contents[content_#{content.id}][body]",
				pages_for_select(pages, content.essence.body, options[:prompt], options[:page_attribute]),
				select_options
			)
		end

		# Returns an Array build for passing it to the options_for_select helper inside an essence editor partial.
		# Usefull for the select_values options from the render_essence_editor helpers.
		# Options:
		#   * :from_page (String, Page) - Return only elements from this page. You can either pass a Page instance, or a page_layout name
		#   * :elements_with_name (Array, String) - Return only elements with this name(s).
		def elements_for_essence_editor_select(options={})
			defaults = {
				:from_page => nil,
				:elements_with_name => nil,
				:prompt => _('Please choose')
			}
			options = defaults.merge(options)
			if options[:from_page]
				page = options[:from_page].is_a?(String) ? Page.find_by_page_layout(options[:from_page]) : options[:from_page]
			end
			if page
				elements = options[:elements_with_name].blank? ? page.elements.find_all_by_public(true) : page.elements.find_all_by_public_and_name(true, options[:elements_with_name])
			else
				elements = options[:elements_with_name].blank? ? Element.find_all_by_public(true) : Element.find_all_by_public_and_name(true, options[:elements_with_name])
			end
			select_options = [[options[:prompt], ""]]
			elements.each do |e|
				select_options << [e.display_name_with_preview_text, e.id.to_s]
			end
			select_options
		end

		# Returns all Pages found in the database as an array for the rails select_tag helper.
		# You can pass a collection of pages to only returns these pages as array.
		# Pass an Page.name or Page.id as second parameter to pass as selected for the options_for_select helper.
		def pages_for_select(pages = nil, selected = nil, prompt = "", page_attribute = :id)
			result = [[prompt.blank? ? _('Choose page') : prompt, ""]]
			if pages.blank?
				pages = Page.find_all_by_language_id_and_public(session[:language_id], true)
			end
			pages.each do |p|
				result << [p.name, p.send(page_attribute).to_s]
			end
			options_for_select(result, selected.to_s)
		end

		def render_essence_selection_editor(element, content, select_options)
			if content.class == String
				content = element.contents.find_by_name(content)
			else
				content = element.contents[content - 1]
			end
			if content.essence.nil?
				return warning('Element', _('content_essence_not_found'))
			end
			select_options = options_for_select(select_options, content.essence.content)
			select_tag(
				"contents[content_#{content.id}]",
				select_options
			)
		end

		def admin_main_navigation
			navigation_entries = alchemy_modules.collect{ |p| p["navigation"] }
			entries = ""
			navigation_entries.flatten.each do |alchemy_module|
				entries << alchemy_main_navigation_entry(alchemy_module)
			end
			entries.html_safe
		end

		def alchemy_main_navigation_entry(alchemy_module)
			render :partial => 'alchemy/admin/partials/mainnavigation_entry', :locals => {:alchemy_module => alchemy_module.stringify_keys}
		end

		def admin_subnavigation
			alchemy_module = module_definition_for(:controller => params[:controller], :action => params[:action])
			unless alchemy_module.nil?
				entries = alchemy_module["navigation"].stringify_keys['sub_navigation']
				render_admin_subnavigation(entries) unless entries.nil?
			else
				""
			end
		end

		# Renders the Subnavigation for the admin interface.
		def render_admin_subnavigation(entries)
			render :partial => "alchemy/admin/partials/sub_navigation", :locals => {:entries => entries}
		end

		def admin_mainnavi_active?(mainnav)
			mainnav.stringify_keys!
			subnavi = mainnav["sub_navigation"].map(&:stringify_keys) if mainnav["sub_navigation"]
			nested = mainnav["nested"].map(&:stringify_keys) if mainnav["nested"]
			if subnavi
				(!subnavi.detect{ |subnav| subnav["controller"] == params[:controller] && subnav["action"] == params[:action] }.blank?) ||
				(nested && !nested.detect{ |n| n["controller"] == params[:controller] && n["action"] == params[:action] }.blank?)
			else
				mainnav["controller"] == params[:controller] && mainnav["action"] == params["action"]
			end
		end

		def parse_sitemap_name(page)
			if multi_language?
				pathname = "/#{session[:language_code]}/#{page.urlname}"
			else
				pathname = "/#{page.urlname}"
			end
			pathname
		end

		# Returns an icon
		def render_icon(icon_class)
			content_tag('span', '', :class => "icon #{icon_class}")
		end

		# Logs a message in the Rails logger (warn level) and optionally displays an error message to the user.
		def warning(message, text = nil)
			logger.warn %(\n
				++++ WARNING: #{message}! from: #{caller.first}\n
			)
			unless text.nil?
				warning = content_tag('p', :class => 'content_editor_error') do
					render_icon('warning') + text
				end
				return warning
			end
		end

		def necessary_options_for_cropping_provided?(options)
			options[:crop].to_s == 'true' && !options[:image_size].blank?
		end

		# Renders translated Module Names for html title element.
		def render_alchemy_title
			key = 'module: ' + controller_name
			if content_for?(:title)
				title = content_for(:title)
			elsif FastGettext.key_exist?(key)
				title = _(key)
			else
				title = controller_name.humanize
			end
			"Alchemy CMS - #{title}"
		end

		# Returns max image count as integer or nil. Used for the picture editor in element editor views.
		def max_image_count
			return nil if !@options
			if @options[:maximum_amount_of_images].blank?
				image_count = @options[:max_images]
			else
				image_count = @options[:maximum_amount_of_images]
			end
			if image_count.blank?
				nil
			else
				image_count.to_i
			end
		end

		def clipboard_select_tag(items, html_options = {})
			options = [[_('Please choose'), ""]]
			items.each do |item|
				options << [item.class.to_s == 'Element' ? item.display_name_with_preview_text : item.name, item.id]
			end
			select_tag(
				'paste_from_clipboard',
				!@page.new_record? && @page.can_have_cells? ? grouped_elements_for_select(items, :id) : options_for_select(options),
				{
					:class => html_options[:class] || 'very_long',
					:style => html_options[:style]
				}
			)
		end

		# Taken from tinymce_hammer plugin
		def append_class_name options, class_name #:nodoc:
			key = options.has_key?('class') ? 'class' : :class 
			unless options[key].to_s =~ /(^|\s+)#{class_name}(\s+|$)/
				options[key] = "#{options[key]} #{class_name}".strip
			end
			options
		end

		# Renders a toolbar button for the Alchemy toolbar
		# 
		# Options:
		# 
		#   :icon             [String]              # Icon class. See base.css.sccs for available icons, or make your own.
		#   :label            [String]              # Text for button label.
		#   :url              [String]              # Url for link.
		#   :title            [String]              # Text for title tag.
		#   :overlay          [Boolean]             # Pass true to open the link in a modal overlay window.
		#   :overlay_options  [Hash]                # Overlay options. See link_to_overlay_window helper.
		# 
		def toolbar_button(options = {})
			options.symbolize_keys!
			defaults = {
				:overlay => true
			}
			options = defaults.merge(options)
			content_tag('div', :class => 'button_with_label') do
				link = if options[:overlay]
					link_to_overlay_window(
						render_icon(options[:icon]),
						options[:url],
						options[:overlay_options],
						{
							:class => 'icon_button',
							:title => options[:title]
						}
					)
				else
					link_to options[:url], :class => 'icon_button', :title => options[:title] do
						render_icon(options[:icon])
					end
				end
				link += content_tag('label', options[:label])
			end
		end

	end
end
