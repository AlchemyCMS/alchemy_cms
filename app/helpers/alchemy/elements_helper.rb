# frozen_string_literal: true

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
    # @option options [String] :separator
    #   A string that will be used to join the element partials. Default nil
    #
    def render_elements(options = {})
      options = {
        from_page: @page,
        render_format: 'html',
        reverse: false
      }.update(options)

      pages = pages_holding_elements(options.delete(:from_page))

      if pages.blank?
        warning('No page to get elements from was found')
        return
      end

      elements = collect_elements_from_pages(pages, options)

      if options[:sort_by].present?
        elements = sort_elements_by_content(
          elements,
          options.delete(:sort_by),
          options[:reverse]
        )
      end

      render_element_view_partials(elements, options)
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
    # @note If the view partial is not found <tt>alchemy/elements/_view_not_found.html.erb</tt>
    #   or <tt>alchemy/elements/_editor_not_found.html.erb</tt> gets rendered.
    #
    def render_element(element, part = :view, options = {}, counter = 1)
      if element.nil?
        warning('Element is nil')
        render "alchemy/elements/#{part}_not_found", {name: 'nil'}
        return
      end

      options = {
        element: element,
        counter: counter,
        options: options,
        locals: options.delete(:locals) || {}
      }

      element.store_page(@page) if part.to_sym == :view
      render "alchemy/elements/#{element.name}_#{part}", options
    rescue ActionView::MissingTemplate => e
      warning(%(
        Element #{part} partial not found for #{element.name}.\n
        #{e}
      ))
      render "alchemy/elements/#{part}_not_found", {
        name: element.name,
        error: "Element #{part} partial not found.<br>Use <code>rails generate alchemy:elements</code> to generate it."
      }
    end

    # Returns a string for the id attribute of a html element for the given element
    def element_dom_id(element)
      return "" if element.nil?
      "#{element.name}_#{element.id}".html_safe
    end

    # Renders the HTML tag attributes required for preview mode.
    def element_preview_code(element)
      if respond_to?(:tag_options)
        tag_options(element_preview_code_attributes(element))
      else
        # Rails 5.1 uses TagBuilder
        tag_builder.tag_options(element_preview_code_attributes(element))
      end
    end

    # Returns a hash containing the HTML tag attributes required for preview mode.
    def element_preview_code_attributes(element)
      return {} unless element.present? && @preview_mode && element.page == @page
      { 'data-alchemy-element' => element.id }
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
      if respond_to?(:tag_options)
        tag_options(element_tags_attributes(element, options))
      else
        # Rails 5.1 uses TagBuilder
        tag_builder.tag_options(element_tags_attributes(element, options))
      end
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
      { 'data-element-tags' => options[:formatter].call(element.tag_list) }
    end

    # Sort given elements by content.
    #
    # @param [Array] elements - The elements you want to sort
    # @param [String] content_name - The name of the content you want to sort by
    # @param [Boolean] reverse - Reverse the sorted elements order
    #
    # @return [Array]
    #
    def sort_elements_by_content(elements, content_name, reverse = false)
      sorted_elements = elements.sort_by do |element|
        content = element.content_by_name(content_name)
        content ? content.ingredient.to_s : ''
      end

      reverse ? sorted_elements.reverse : sorted_elements
    end

    private

    def pages_holding_elements(page)
      case page
      when String
        Language.current.pages.where(
          page_layout: page,
          restricted: false
        ).to_a
      when Page
        page
      end
    end

    def collect_elements_from_pages(page, options)
      if page.is_a? Array
        elements = page.collect { |p| p.find_elements(options) }.flatten
      else
        elements = page.find_elements(options)
      end
      if fallback_required?(elements, options)
        elements += fallback_elements(options)
      end
      elements
    end

    def fallback_required?(elements, options)
      options[:fallback] && elements.detect { |e| e.name == options[:fallback][:for] }.nil?
    end

    def fallback_elements(options)
      fallback_options = options.delete(:fallback)
      case fallback_options[:from]
      when String
        page = Language.current.pages.find_by(
          page_layout: fallback_options[:from],
          restricted: false
        )
      when Page
        page = fallback_options[:from]
      end
      return [] if page.blank?
      page.elements.not_trashed.named(fallback_options[:with].presence || fallback_options[:for])
    end

    def render_element_view_partials(elements, options = {})
      buff = []
      elements.each_with_index do |element, i|
        buff << render_element(element, :view, options, i + 1)
      end
      buff.join(options[:separator]).html_safe
    end
  end
end
