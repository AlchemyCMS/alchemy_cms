module Alchemy
	module Admin
		
		# This module contains helper methods for rendering overlay windows, toolbar buttons and confirmation windows.
		# 
		# The most important helpers for module developers are:
		# 
		# * toolbar
		# * toolbar_button
		# * link_to_overlay_window
		# * link_to_confirmation_window
		# 
		module BaseHelper

			# This helper renders the link for an overlay window.
			# 
			# We use this for our fancy modal overlay windows in the Alchemy cockpit.
			# 
			# === Options:
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

			# (internal) Used for rendering the folder link in +Admin::Pages#index+ sitemap.
			def sitemapFolderLink(page)
				return '' if page.level == 1
				if page.folded?(current_user.id)
					css_class = 'folded'
					title = t('Show childpages')
				else
					css_class = 'collapsed'
					title = t('Hide childpages')
				end
				link_to(
					'',
					alchemy.fold_admin_page_path(page),
					:remote => true,
					:method => :post,
					:class => "page_folder #{css_class}",
					:title => title,
					:id => "fold_button_#{page.id}"
				)
			end

			# Used for language selector in Alchemy cockpit sitemap. So the user can select the language branche of the page.
			def language_codes_for_select
				configuration(:languages).collect{ |language|
					language[:language_code]
				}
			end

			# Used for translations selector in Alchemy cockpit user settings.
			def translations_for_select
				Alchemy::I18n.available_locales.map do |locale|
					[t(locale, :scope => :translations), locale]
				end
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
					:title => t("click_to_show_all")
				)
				filter_field << "<label for=\"search_field\">" + t("search") + "</label>"
				filter_field << "</div>"
				filter_field.html_safe
			end

			# Returns a link that opens a modal confirmation window.
			# 
			# === Parameters:
			# 
			# 1. The content inside the <a> tag
			# 2. The message that is displayed in the overlay window
			# 3. The url that gets opened after confirmation (Note: This is an Ajax request with a method of DELETE!)
			# 4. html options get passed to the link
			# 
			# === Example:
			# 
			#   <%= link_to_confirmation_window('delete', 'Do you really want to delete this comment?', '/admin/comments/1') %>
			# 
			def link_to_confirmation_window(link_string = "", message = "", url = "", html_options = {})
				title = t("please_confirm")
				ok_lable = t("Yes")
				cancel_lable = t("No")
				link_to_function(
					link_string,
					"Alchemy.confirmToDeleteWindow('#{url}', '#{title}', '#{message}', '#{ok_lable}', '#{cancel_lable}');",
					html_options
				)
			end

			# Returns an Array build for passing it to the options_for_select helper inside an essence editor partial.
			# Usefull for the select_values options from the render_essence_editor helpers.
			# 
			# == Options:
			# 
			#   :from_page            [String, Page]     # Return only elements from this page. You can either pass a Page instance, or a page_layout name
			#   :elements_with_name   [Array, String]    # Return only elements with this name(s).
			# 
			def elements_for_essence_editor_select(options={})
				defaults = {
					:from_page => nil,
					:elements_with_name => nil,
					:prompt => t('Please choose')
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

			# Returns all public pages found in the database as an Array suitable or the Rails +select_tag+ helper.
			# 
			# * You can pass a collection of pages so it only returns these pages and does not query the database.
			# * Pass a +Page#name+ or +Page#id+ as second parameter to be passed as selected item to the +options_for_select+ helper.
			# * The trhird parameter is used as prompt message in the select tag
			# * The last parameter is the method that is called on the page object to get the value that is passed with the params of the form.
			# 
			def pages_for_select(pages = nil, selected = nil, prompt = "", page_attribute = :id)
				result = [[prompt.blank? ? t('Choose page') : prompt, ""]]
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
					return warning('Element', t('content_essence_not_found'))
				end
				select_options = options_for_select(select_options, content.essence.content)
				select_tag(
					"contents[content_#{content.id}]",
					select_options
				)
			end

			def admin_main_navigation
				entries = ""
				alchemy_modules.each do |alchemy_module|
					entries << alchemy_main_navigation_entry(alchemy_module)
				end
				entries.html_safe
			end

			def alchemy_main_navigation_entry(alchemy_module)
				render 'alchemy/admin/partials/main_navigation_entry', :alchemy_module => alchemy_module.stringify_keys, :navigation => alchemy_module['navigation'].stringify_keys
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
				render "alchemy/admin/partials/sub_navigation_tab", :entries => entries
			end

			# Used for checking the main navi permissions
			def navigate_module(navigation)
				[navigation["action"].to_sym, navigation["controller"].gsub(/^\//, '').gsub(/\//, '_').to_sym]
			end

			# Returns true if the current controller and action is in a modules navigation definition.
			def admin_mainnavi_active?(mainnav)
				mainnav.stringify_keys!
				subnavi = mainnav["sub_navigation"].map(&:stringify_keys) if mainnav["sub_navigation"]
				nested = mainnav["nested"].map(&:stringify_keys) if mainnav["nested"]
				if subnavi
					(!subnavi.detect{ |subnav| subnav["controller"].gsub(/^\//, '') == params[:controller] && subnav["action"] == params[:action] }.blank?) ||
					(nested && !nested.detect{ |n| n["controller"] == params[:controller] && n["action"] == params[:action] }.blank?)
				else
					mainnav["controller"] == params[:controller] && mainnav["action"] == params["action"]
				end
			end

			# Calls the url_for helper on either an alchemy module engine, or the app alchemy is mounted at.
			def url_for_module(alchemy_module)
				navigation = alchemy_module['navigation'].stringify_keys
				url_options = {
					:controller => navigation['controller'],
					:action => navigation['action']
				}
				if alchemy_module['engine_name']
					eval(alchemy_module['engine_name']).url_for(url_options)
				else
					main_app.url_for(url_options)
				end
			end

			# Calls the url_for helper on either an alchemy module engine, or the app alchemy is mounted at.
			def url_for_module_sub_navigation(navigation)
				alchemy_module = module_definition_for(navigation)
				engine_name = alchemy_module['engine_name'] if alchemy_module
				navigation.stringify_keys!
				url_options = {
					:controller => navigation['controller'],
					:action => navigation['action']
				}
				if engine_name
					eval(engine_name).url_for(url_options)
				else
					main_app.url_for(url_options)
				end
			end

			def main_navigation_css_classes(navigation)
				['main_navi_entry', admin_mainnavi_active?(navigation) ? 'active' : nil].compact.join(" ")
			end

			# (internal) Renders translated Module Names for html title element.
			def render_alchemy_title
				if content_for?(:title)
					title = content_for(:title)
				else
					title = t(controller_name, :scope => :modules)
				end
				"Alchemy CMS - #{title}"
			end

			# (internal) Returns max image count as integer or nil. Used for the picture editor in element editor views.
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

			# (internal) Renders a select tag for all items in the clipboard
			def clipboard_select_tag(items, html_options = {})
				options = [[t('Please choose'), ""]]
				items.each do |item|
					options << [item.class.to_s == 'Element' ? item.display_name_with_preview_text : item.name, item.id]
				end
				select_tag(
					'paste_from_clipboard',
					!@page.new_record? && @page.can_have_cells? ? grouped_elements_for_select(items, :id) : options_for_select(options),
					{
						:class => html_options[:class],
						:style => html_options[:style]
					}
				)
			end

			# Renders a toolbar button for the Alchemy toolbar
			# 
			# == Options:
			# 
			#   :icon                   [String]              # Icon class. See base.css.sccs for available icons, or make your own.
			#   :label                  [String]              # Text for button label.
			#   :url                    [String]              # Url for link.
			#   :title                  [String]              # Text for title tag.
			#   :overlay                [Boolean]             # Pass true to open the link in a modal overlay window.
			#   :overlay_options        [Hash]                # Overlay options. See link_to_overlay_window helper.
			#   :if_permitted_to        [Array]               # Check permission for button. [:action, :controller]. Exactly how you defined the permission in your +authorization_rules.rb+. Defaults to controller and action from button url.
			#   :skip_permission_check  [Boolean]             # Skip the permission check. Default false. NOT RECOMMENDED!
			#   :loading_indicator      [Boolean]             # Shows the please wait overlay while loading. Default false.
			# 
			def toolbar_button(options = {})
				options.symbolize_keys!
				defaults = {
					:overlay => true,
					:skip_permission_check => false,
					:active => false,
					:link_options => {},
					:overlay_options => {},
					:loading_indicator => false
				}
				options = defaults.merge(options)
				button = content_tag('div', :class => 'button_with_label' + (options[:active] ? ' active' : '')) do
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
						link_to options[:url], {:class => "icon_button#{options[:loading_indicator] ? nil : ' please_wait'}", :title => options[:title]}.merge(options[:link_options]) do
							render_icon(options[:icon])
						end
					end
					link += content_tag('label', options[:label])
				end
				if options[:skip_permission_check]
					return button
				else
					if options[:if_permitted_to].blank?
						action_controller = options[:url].gsub(/^\//, '').split('/')
						options[:if_permitted_to] = [action_controller.last.to_sym, action_controller[0..action_controller.length-2].join('_').to_sym]
					end
					if permitted_to?(*options[:if_permitted_to])
						return button
					else
						return ""
					end
				end
			end

			# Renders the Alchemy backend toolbar
			# 
			# == Options
			# 
			#   :buttons  [Array]          # Pass an Array with button options. They will be passed to toolbar_button helper. For options see toolbar_button
			#   :search   [Boolean]        # Show searchfield. Default true.
			# 
			def toolbar(options = {})
				defaults = {
					:buttons => [],
					:search => true
				}
				options = defaults.merge(options)
				content_for(:toolbar) do
					content = <<-CONTENT
						#{options[:buttons].map { |button_options| toolbar_button(button_options) }.join()}
						#{render('alchemy/admin/partials/search_form', :url => options[:search_url]) if options[:search]}
					CONTENT
					content.html_safe
				end
			end

			# Renders the row for a resource record in the resources table.
			# 
			# This helper has a nice fallback. If you create a partial for your record then this partial will be rendered.
			# 
			# Otherwise the default +app/views/alchemy/admin/resources/_resource.html.erb+ partial gets rendered.
			# 
			# == Example
			# 
			# For a resource named +Comment+ you can create a partial named +_comment.html.erb+
			# 
			#   # app/views/admin/comments/_comment.html.erb
			#   <tr>
			#     <td><%= comment.title %></td>
			#     <td><%= comment.body %></td>
			#   </tr>
			# 
			# NOTE: Alchemy gives you a local variable named like your resource
			# 
			def render_resources
				render resources_instance_variable
			rescue ActionView::MissingTemplate
				render :partial => 'resource', :collection => resources_instance_variable
			end

			# (internal) Used by upload form
			def new_asset_path_with_session_information(asset_type)
				session_key = Rails.application.config.session_options[:key]
				if asset_type == "picture"
					alchemy.admin_pictures_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token, :format => :js)
				elsif asset_type == "attachment"
					alchemy.admin_attachments_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token, :format => :js)
				end
			end

			# Renders a textfield ready to display a datepicker
			# 
			# Uses a HTML5 +input type="date"+ field.
			# 
			# Pass a type as third option to override that. But old browsers hand this as text field anyway. So there is no need to override that.
			# 
			# === Example
			# 
			#   <%= alchemy_datepicker(@person, :birthday) %>
			# 
			def alchemy_datepicker(object, method, html_options={})
				text_field(object.class.name.underscore.to_sym, method.to_sym, {
					:type => 'date',
					:class => 'thin_border date',
					:value => object.send(method.to_sym).nil? ? nil : l(object.send(method.to_sym), :format => :datepicker)
				}.merge(html_options))
			end

		end
	end
end
