module Alchemy
	module ElementsHelper

		include Alchemy::EssencesHelper

		# Renders all elements from current page.
		# 
		# === Options are:
		# 
		#   :only => []                          # A list of element names to be rendered only. Very useful if you want to render a specific element type in a special html part (e.g.. <div>) of your page and all other elements in another part.
		#   :except => []                        # A list of element names to be rendered. The opposite of the only option.
		#   :from_page                           # The Alchemy::Page.page_layout string from which the elements are rendered from, or you even pass a Page object.
		#   :count                               # The amount of elements to be rendered (begins with first element found)
		#   :fallback => {                       # You can use the fallback option as an override. So you can take elements from a glo´bal laout page and only if the user adds an element on current page the local one gets rendered.
		#     :for => 'ELEMENT_NAME',            # The name of the element the fallback is for
		#     :with => 'ELEMENT_NAME',           # (OPTIONAL) the name of element to fallback with
		#     :from => 'PAGE_LAYOUT'             # The page_layout name from the global page the fallback elements lie on. I.E 'left_column'
		#   }                                    # 
		#   :sort_by => Content#name             # A Content name to sort the elements by
		#   :reverse => boolean                  # Reverse the rendering order
		#   :random => boolean                   # Randomize the output of elements
		# 
		# === Note:
		# This helper also stores all pages where elements gets rendered on, so we can sweep them later if caching expires!
		# 
		def render_elements(options = {})
			default_options = {
				:except => [],
				:only => [],
				:from_page => "",
				:from_cell => nil,
				:count => nil,
				:offset => nil,
				:locals => {},
				:render_format => "html",
				:fallback => nil
			}
			options = default_options.merge(options)
			if options[:from_page].blank?
				page = @page
			else
				if options[:from_page].class == Page
					page = options[:from_page]
				else
					page = Page.where(:page_layout => options[:from_page]).with_language(session[:language_id]).all
				end
			end
			if page.blank?
				warning('Page is nil')
				return ""
			else
				show_non_public = configuration(:cache_pages) ? false : defined?(current_user)
				if page.class == Array
					all_elements = page.collect { |p| p.find_elements(options, show_non_public) }.flatten
				else
					all_elements = page.find_elements(options, show_non_public)
				end
				unless options[:sort_by].blank?
					all_elements = all_elements.sort_by { |e| e.contents.detect { |c| c.name == options[:sort_by] }.ingredient }
				end
				all_elements.reverse! if options[:reverse_sort] || options[:reverse]
				element_string = ""
				if options[:fallback]
					unless all_elements.detect { |e| e.name == options[:fallback][:for] }
						if from = Page.where(:page_layout => options[:fallback][:from]).with_language(session[:language_id]).first
							all_elements += from.elements.named(options[:fallback][:with].blank? ? options[:fallback][:for] : options[:fallback][:with])
						end
					end
				end
				all_elements.each_with_index do |element, i|
					element_string += render_element(element, :view, options, i+1)
				end
				element_string.html_safe
			end
		end

		# This helper renders the Element partial for either the view or the editor part.
		# Generate element partials with ./script/generate elements
		def render_element(element, part = :view, options = {}, i = 1)
			begin
				if element.blank?
					warning('Element is nil')
					render :partial => "alchemy/elements/#{part}_not_found", :locals => {:name => 'nil'}
				else
					default_options = {
						:shorten_to => nil,
						:render_format => "html"
					}
					options = default_options.merge(options)
					element.store_page(@page) if part == :view
					path1 = "#{Rails.root}/app/views/elements/"
					path2 = "#{Rails.root}/vendor/plugins/alchemy/app/views/elements/"
					partial_name = "_#{element.name.underscore}_#{part}.html.erb"
					locals = options.delete(:locals)
					render(
						:partial => "alchemy/elements/#{element.name.underscore}_#{part}.#{options[:render_format]}.erb",
						:locals => {
							:element => element,
							:options => options,
							:counter => i
						}.merge(locals || {})
					)
				end
			rescue ActionView::MissingTemplate
				warning(%(
					Element #{part} partial not found for #{element.name}.\n
					Looking for #{partial_name}, but not found
					neither in #{path1}
					nor in #{path2}
					Use rails generate alchemy:elements to generate them.
					Maybe you still have old style partial names? (like .rhtml). Then please rename them in .html.erb'
				))
				render :partial => "alchemy/elements/#{part}_not_found", :locals => {:name => element.name, :error => "Element #{part} partial not found. Use rails generate alchemy:elements to generate them."}
			end
		end

		# Returns all public elements found by Element.name.
		# Pass a count to return only an limited amount of elements.
		def all_elements_by_name(name, options = {})
			warning('options[:language] option not allowed any more in all_elements_by_name helper') unless options[:language].blank?
			default_options = {
				:count => :all,
				:from_page => :all
			}
			options = default_options.merge(options)
			if options[:from_page] == :all
				elements = Element.find_all_by_name_and_public(name, true, :limit => options[:count] == :all ? nil : options[:count])
			elsif options[:from_page].class == String
				page = Page.find_by_page_layout_and_language_id(options[:from_page], session[:language_id])
				return [] if page.blank?
				elements = page.elements.find_all_by_name_and_public(name, true, :limit => options[:count] == :all ? nil : options[:count])
			else
				elements = options[:from_page].elements.find_all_by_name_and_public(name, true, :limit => options[:count] == :all ? nil : options[:count])
			end
		end

		# Returns the public element found by Element.name from the given public Page, either by Page.id or by Page.urlname
		def element_from_page(options = {})
			default_options = {
				:page_urlname => "",
				:page_id => nil,
				:element_name => ""
			}
			options = default_options.merge(options)
			if options[:page_id].blank?
				page = Page.find_by_urlname_and_public(options[:page_urlname], true)
			else
				page = Page.find_by_id_and_public(options[:page_id], true)
			end
			return "" if page.blank?
			element = page.elements.find_by_name_and_public(options[:element_name], true)
			return element
		end

		# Renders all element partials from given cell.
		def render_cell_elements(cell)
			return warning("No cell given.") if cell.blank?
			render_elements({:from_cell => cell})
		end

		# Returns a string for the id attribute of a html element for the given element
		def element_dom_id(element)
			return "" if element.nil?
			"#{element.name}_#{element.id}"
		end

		# Renders the data-alchemy-element HTML attribut used for the preview window hover effect.
		def element_preview_code(element)
			return "" if element.nil?
			" data-alchemy-element='#{element.id}'" if @preview_mode && element.page == @page
		end

		# Returns the full url containing host, page and anchor for the given element
		def full_url_for_element(element)
			"http://" + request.env["HTTP_HOST"] + "/" + element.page.urlname + "##{element.name}_#{element.id}"  
		end

	end
end
