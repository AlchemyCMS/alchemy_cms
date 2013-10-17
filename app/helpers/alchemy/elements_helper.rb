module Alchemy
  # This helpers are useful to render elements from pages.
  #
  # The most important helper for frontend developers is the {#render_elements} helper.
  #
  module ElementsHelper
    include Alchemy::EssencesHelper
    include Alchemy::UrlHelper
    include Alchemy::ElementsBlockHelper

    # Renders all elements from current page
    #
    # == Examples:
    #
    # === Render only certain elements:
    #
    #   <header>
    #     <%= render_elements only: ['header', 'claim'] %>
    #   </header>
    #   <section id="content">
    #     <%= render_elements except: ['header', 'claim'] %>
    #   </section>
    #
    # === Render elements from global page:
    #
    #   <footer>
    #     <%= render_elements from_page: 'footer' %>
    #   </footer>
    #
    # === Render elements from cell:
    #
    #   <aside>
    #     <%= render_elements from_cell: 'sidebar' %>
    #   </aside>
    #
    # === Fallback to elements from global page:
    #
    # You can use the fallback option as an override for elements that are stored on another page.
    # So you can take elements from a global page and only if the user adds an element on current page the
    # local one gets rendered.
    #
    # 1. You have to pass the the name of the element the fallback is for as <tt>for</tt> key.
    # 2. You have to pass a <tt>page_layout</tt> name or {Alchemy::Page} from where the fallback elements is taken from as <tt>from</tt> key.
    # 3. You can pass the name of element to fallback with as <tt>with</tt> key. This is optional (the element name from the <tt>for</tt> key is taken as default).
    #
    #   <%= render_elements(fallback: {
    #     for: 'contact_teaser',
    #     from: 'sidebar',
    #     with: 'contact_teaser'
    #   }) %>
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [Number] :count
    #   The amount of elements to be rendered (begins with first element found)
    # @option options [Array or String] :except ([])
    #   A list of element names not to be rendered.
    # @option options [Hash] :fallback
    #   Define elements that are rendered from another page.
    # @option options [Alchemy::Cell or String] :from_cell
    #   The cell the elements are rendered from. You can pass a {Alchemy::Cell} name String or a {Alchemy::Cell} object.
    # @option options [Alchemy::Page or String] :from_page (@page)
    #   The page the elements are rendered from. You can pass a page_layout String or a {Alchemy::Page} object.
    # @option options [Array or String] :only ([])
    #   A list of element names only to be rendered.
    # @option options [Boolean] :random
    #   Randomize the output of elements
    # @option options [Boolean] :reverse
    #   Reverse the rendering order
    # @option options [String] :sort_by
    #   The name of a {Alchemy::Content} to sort the elements by
    #
    def render_elements(options = {})
      default_options = {
        :except => [],
        :only => [],
        :from_page => @page,
        :from_cell => nil,
        :count => nil,
        :offset => nil,
        :locals => {},
        :render_format => "html",
        :fallback => nil
      }
      options = default_options.merge(options)
      if options[:from_page].class == Page
        page = options[:from_page]
      else
        page = Page.where(:page_layout => options[:from_page]).with_language(session[:language_id]).to_a
      end
      if page.blank?
        warning('Page is nil')
        return ""
      else
        if page.class == Array
          all_elements = page.collect { |p| p.find_elements(options) }.flatten
        else
          all_elements = page.find_elements(options)
        end
        if options[:sort_by].present?
          all_elements = all_elements.sort_by { |e| e.contents.detect { |c| c.name == options[:sort_by] }.ingredient }
        end
        element_string = ""
        if options[:fallback]
          if all_elements.detect { |e| e.name == options[:fallback][:for] }.blank?
            if options[:fallback][:from].class.name == 'Alchemy::Page'
              from = options[:fallback][:from]
            else
              from = Page.not_restricted.where(:page_layout => options[:fallback][:from]).with_language(session[:language_id]).first
            end
            if from
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

    # This helper renders a {Alchemy::Element} partial.
    #
    # A element has always two partials:
    #
    # 1. A view partial (This is the view presented to the website visitor)
    # 2. A editor partial (This is the form presented to the website editor while in page edit mode)
    #
    # The partials are located in <tt>app/views/alchemy/elements</tt>.
    #
    # == View partial naming
    #
    # The partials have to be named after the name of the element as defined in the <tt>elements.yml</tt> file and has to be suffixed with the partial part.
    #
    # === Example
    #
    # Given a headline element
    #
    #   # elements.yml
    #   - name: headline
    #     contents:
    #     - name: text
    #       type: EssenceText
    #
    # Then your element view partials has to be named like:
    #
    #   app/views/alchemy/elements/_headline_editor.html.erb
    #   app/views/alchemy/elements/_headline_view.html.erb
    #
    # === Element partials generator
    #
    # You can use this handy generator to let Alchemy generate the partials for you:
    #
    #   $ rails generate alchemy:elements --skip
    #
    # == Usage
    #
    #   <%= render_element(Alchemy::Element.published.named(:headline).first) %>
    #
    # @param [Alchemy::Element] element
    #   The element you want to render the view for
    # @param [Symbol] part
    #   The type of element partial (<tt>:editor</tt> or <tt>:view</tt>) you want to render
    # @param [Hash] options
    #   Additional options
    # @param [Number] counter
    #   a counter
    #
    # @note If the view partial is not found <tt>alchemy/elements/_view_not_found.html.erb</tt> or <tt>alchemy/elements/_editor_not_found.html.erb</tt> gets rendered.
    #
    def render_element(element, part = :view, options = {}, counter = 1)
      begin
        if element.blank?
          warning('Element is nil')
          render :partial => "alchemy/elements/#{part}_not_found", :locals => {:name => 'nil'}
        else
          element.store_page(@page) if part == :view
          locals = options.delete(:locals)
          render(
            :partial => "alchemy/elements/#{element.name.underscore}_#{part}",
            :locals => {
              :element => element,
              :counter => counter,
              :options => options
            }.merge(locals || {})
          )
        end
      rescue ActionView::MissingTemplate => e
        warning(%(
          Element #{part} partial not found for #{element.name}.\n
          #{e}
        ))
        render :partial => "alchemy/elements/#{part}_not_found", :locals => {:name => element.name, :error => "Element #{part} partial not found.<br>Use <code>rails generate alchemy:elements</code> to generate it."}
      end
    end

    # This helper returns all published elements with the given name.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [Number] :count
    #   The amount of elements to be returned.
    #
    # @option options [Alchemy::Page/String] :from_page
    #   Only elements associated with this page are returned.
    #
    # @note When passing a String for options :from_page, it must be a page_layout name.
    #
    def all_elements_by_name(name, options = {})
      warning('options[:language] option not allowed any more in all_elements_by_name helper') unless options[:language].blank?
      options = {
        count: :all,
        from_page: :all
      }.merge(options)

      case options[:from_page]
      when :all
        return Element.published.where(name: name).limit(options[:count] == :all ? nil : options[:count])
      when String
        page = Page.with_language(session[:language_id]).find_by_page_layout(options[:from_page])
      else
        page = options[:from_page]
      end

      return [] if page.blank?
      page.elements.published.where(name: name).limit(options[:count] == :all ? nil : options[:count])
    end

    # This helper returns a published element found by the given name and the given published Page, either by Page.id or by Page.urlname
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [String] :page_urlname
    #   The urlname of the Page the element is associated with
    #
    # @option options [Integer] :page_id
    #   The id of the Page the element is associated with
    #
    def element_from_page(options = {})
      default_options = {
        page_urlname: "",
        page_id: nil,
        element_name: ""
      }.merge(options)

      page = case options[:page_id]
      when nil
        Page.published.find_by_urlname(options[:page_urlname])
      else
        Page.published.find_by_id(options[:page_id])
      end

      return "" if page.blank?
      page.elements.published.find_by_name(options[:element_name])
    end

    # Renders all element partials from given cell.
    def render_cell_elements(cell)
      return warning("No cell given.") if cell.blank?
      render_elements({:from_cell => cell})
    end

    # Returns a string for the id attribute of a html element for the given element
    def element_dom_id(element)
      return "" if element.nil?
      "#{element.name}_#{element.id}".html_safe
    end

    # Renders the HTML tag attributes required for preview mode.
    def element_preview_code(element)
      tag_options(element_preview_code_attributes(element))
    end

    # Returns a hash containing the HTML tag attributes required for preview mode.
    def element_preview_code_attributes(element)
      return {} unless element.present? && @preview_mode && element.page == @page
      { :'data-alchemy-element' => element.id }
    end

    # Returns the full url containing host, page and anchor for the given element
    def full_url_for_element(element)
      "#{current_server}/#{element.page.urlname}##{element_dom_id(element)}"
    end

    # Returns the element's tags information as a string. Parameters and options
    # are equivalent to {#element_tags_attributes}.
    #
    # @see #element_tags_attributes
    #
    # @return [String]
    #   HTML tag attributes containing the element's tag information.
    #
    def element_tags(element, options = {})
      tag_options(element_tags_attributes(element, options))
    end

    # Returns the element's tags information as an attribute hash.
    #
    # @param [Alchemy::Element] element The {Alchemy::Element} you want to render the tags from.
    #
    # @option options [Proc] :formatter
    #   ('lambda { |tags| tags.join(' ') }')
    #   Lambda converting array of tags to a string.
    #
    # @return [Hash]
    #   HTML tag attributes containing the element's tag information.
    #
    def element_tags_attributes(element, options = {})
      options = {
        formatter: lambda { |tags| tags.join(' ') }
      }.merge(options)

      return {} if !element.taggable? || element.tag_list.blank?
      { :'data-element-tags' => options[:formatter].call(element.tag_list) }
    end

  end
end
