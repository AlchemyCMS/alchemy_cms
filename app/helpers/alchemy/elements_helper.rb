# frozen_string_literal: true

module Alchemy
  # This helpers are useful to render elements from pages.
  #
  # The most important helper for frontend developers is the {#render_elements} helper.
  #
  module ElementsHelper
    include Alchemy::UrlHelper
    include Alchemy::ElementsBlockHelper

    # Renders elements from given page
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
    #     <%= render_elements from_page: Alchemy::Page.find_by(page_layout: 'footer') %>
    #   </footer>
    #
    # === Custom elements finder:
    #
    # Having a custom element finder class:
    #
    #   class MyCustomNewsArchive
    #     def elements(page:)
    #       news_page.elements.named('news').order(created_at: :desc)
    #     end
    #
    #     private
    #
    #     def news_page
    #       Alchemy::Page.where(page_layout: 'news-archive')
    #     end
    #   end
    #
    # In your view:
    #
    #   <div class="news-archive">
    #     <%= render_elements finder: MyCustomNewsArchive.new %>
    #   </div>
    #
    # @option options [Alchemy::Page] :from_page (@page)
    #   The page the elements are rendered from.
    # @option options [Array<String>|String] :only
    #   A list of element names only to be rendered.
    # @option options [Array<String>|String] :except
    #   A list of element names not to be rendered.
    # @option options [Number] :count
    #   The amount of elements to be rendered (begins with first element found)
    # @option options [Number] :offset
    #   The offset to begin loading elements from
    # @option options [Boolean] :random (false)
    #   Randomize the output of elements
    # @option options [Boolean] :reverse (false)
    #   Reverse the rendering order
    # @option options [String] :separator
    #   A string that will be used to join the element partials.
    # @option options [Class] :finder (Alchemy::ElementsFinder)
    #   A class instance that will return elements that get rendered.
    #   Use this for your custom element loading logic in views.
    #
    def render_elements(options = {})
      options = {
        from_page: @page,
        render_format: "html",
      }.update(options)

      finder = options[:finder] || Alchemy::ElementsFinder.new(options)

      page_version = if @preview_mode
          options[:from_page]&.draft_version
        else
          options[:from_page]&.public_version
        end

      elements = finder.elements(page_version: page_version)

      buff = []
      elements.each_with_index do |element, i|
        buff << render_element(element, options, i + 1)
      end
      buff.join(options[:separator]).html_safe
    end

    # This helper renders a {Alchemy::Element} view partial.
    #
    # A element view partial is the html snippet presented to the website visitor.
    #
    # The partial is located in <tt>app/views/alchemy/elements</tt>.
    #
    # == View partial naming
    #
    # The partial has to be named after the name of the element as defined in the <tt>elements.yml</tt> file.
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
    # Then your element view partial has to be named like:
    #
    #   app/views/alchemy/elements/_headline.html.{erb|haml|slim}
    #
    # === Element partials generator
    #
    # You can use this handy generator to let Alchemy generate the partials for you:
    #
    #   $ rails generate alchemy:elements --skip
    #
    # == Usage
    #
    #   <%= render_element(Alchemy::Element.available.named(:headline).first) %>
    #
    # @param [Alchemy::Element] element
    #   The element you want to render the view for
    # @param [Hash] options
    #   Additional options
    # @param [Number] counter
    #   a counter
    #
    # @note If the view partial is not found
    #   <tt>alchemy/elements/_view_not_found.html.erb</tt> gets rendered.
    #
    def render_element(element, options = {}, counter = 1)
      if element.nil?
        warning("Element is nil")
        render "alchemy/elements/view_not_found", { name: "nil" }
        return
      end

      element.store_page(@page)

      render element, {
        element: element,
        counter: counter,
        options: options,
      }.merge(options.delete(:locals) || {})
    rescue ActionView::MissingTemplate => e
      warning(%(
        Element view partial not found for #{element.name}.\n
        #{e}
      ))
      render "alchemy/elements/view_not_found", name: element.name
    end

    # Returns a string for the id attribute of a html element for the given element
    def element_dom_id(element)
      return "" if element.nil?

      "#{element.name}_#{element.id}".html_safe
    end

    # Renders the HTML tag attributes required for preview mode.
    def element_preview_code(element)
      tag_builder.tag_options(element_preview_code_attributes(element))
    end

    # Returns a hash containing the HTML tag attributes required for preview mode.
    def element_preview_code_attributes(element)
      return {} unless element.present? && @preview_mode && element.page == @page

      { "data-alchemy-element" => element.id }
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
      tag_builder.tag_options(element_tags_attributes(element, options))
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
        formatter: lambda { |tags| tags.join(" ") },
      }.merge(options)

      return {} if !element.taggable? || element.tag_list.blank?

      { "data-element-tags" => options[:formatter].call(element.tag_list) }
    end
  end
end
