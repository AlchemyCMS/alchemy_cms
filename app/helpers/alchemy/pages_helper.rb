# frozen_string_literal: true

module Alchemy
  module PagesHelper
    include Alchemy::BaseHelper
    include Alchemy::ElementsHelper

    def picture_essence_caption(content)
      content.try(:essence).try(:caption)
    end

    # Renders links to language root pages of all published languages.
    #
    # @option options linkname [String] ('name')
    #   Renders name/code of language, or I18n translation for code.
    #
    # @option options show_title [Boolean] (true)
    #   Renders title attributes for the links.
    #
    # @option options spacer [String] ('')
    #   Renders the passed spacer string. You can also overwrite the spacer partial: "alchemy/language_links/_spacer".
    #
    # @option options reverse [Boolean] (false)
    #   Reverses the ordering of the links.
    #
    def language_links(options = {})
      options = {
        linkname: "name",
        show_title: true,
        spacer: "",
        reverse: false,
      }.merge(options)
      languages = Language.on_current_site.published.with_root_page.order("name #{options[:reverse] ? "DESC" : "ASC"}")
      return nil if languages.count < 2

      render(
        partial: "alchemy/language_links/language",
        collection: languages,
        spacer_template: "alchemy/language_links/spacer",
        locals: { languages: languages, options: options },
      )
    end

    # Renders the layout for current page.
    #
    # Page layout files belongs in +/app/views/alchemy/page_layouts/+
    #
    # Falls back to +/app/views/alchemy/page_layouts/standard+ if the page_layout partial is not found.
    #
    def render_page_layout
      render @page, page: @page
    rescue ActionView::MissingTemplate
      warning("PageLayout: '#{@page.page_layout}' not found. Rendering standard page_layout.")
      render "alchemy/page_layouts/standard", page: @page
    end

    # Renders a partial for current site
    #
    # Place a rails partial into +app/views/alchemy/site_layouts+
    #
    # and name it like your site name.
    #
    # == Example:
    #
    #   <%= render_site_layout %>
    #
    # renders +app/views/alchemy/site_layouts/_default_site.html.erb+ for the site named "Default Site".
    #
    def render_site_layout(&block)
      render current_alchemy_site, &block
    rescue ActionView::MissingTemplate
      warning("Site layout for #{current_alchemy_site.try(:name)} not found. Please run `rails g alchemy:site_layouts`")
      ""
    end

    # Renders a menu partial
    #
    # Menu partials are placed in the `app/views/alchemy/menus` folder
    # Use the `rails g alchemy:menus` generator to create the partials
    #
    # @param [String] - Type of the menu
    # @param [Hash] - A set of options available in your menu partials
    def render_menu(menu_type, options = {})
      root_node = Alchemy::Node.roots.find_by(
        menu_type: menu_type,
        language: Alchemy::Language.current,
      )
      if root_node.nil?
        warning("Menu with type #{menu_type} not found!")
        return
      end

      render("alchemy/menus/#{menu_type}/wrapper", menu: root_node, options: options)
    rescue ActionView::MissingTemplate => e
      warning <<~WARN
        Menu partial not found for #{menu_type}.
        #{e}
      WARN
    end

    # Returns true if page is in the active branch
    def page_active?(page)
      @_page_ancestors ||= Page.ancestors_for(@page)
      @_page_ancestors.include?(page)
    end

    # Returns page links in a breadcrumb beginning from root to current page.
    #
    # === Options:
    #
    #   separator: %(<span class="separator">></span>)      # Maybe you don't want this separator. Pass another one.
    #   page: @page                                         # Pass a different Page instead of the default (@page).
    #   without: nil                                        # Pass Page object or array of Pages that must not be displayed.
    #   restricted_only: false                              # Pass boolean for displaying restricted pages only.
    #   reverse: false                                      # Pass boolean for displaying breadcrumb in reversed reversed.
    #
    def render_breadcrumb(options = {})
      options = {
        separator: ">",
        page: @page,
        restricted_only: false,
        reverse: false,
        link_active_page: false,
      }.merge(options)

      pages = options[:page].
        self_and_ancestors.contentpages.
        published

      if options.delete(:restricted_only)
        pages = pages.restricted
      end

      if options.delete(:reverse)
        pages = pages.reorder("lft DESC")
      end

      if options[:without].present?
        without = options.delete(:without)
        pages = pages.where.not(id: without.try(:collect, &:id) || without.id)
      end

      render "alchemy/breadcrumb/wrapper", pages: pages, options: options
    end

    # Returns current page title
    #
    # === Options:
    #
    #   prefix: ""                 # Prefix
    #   separator: ""              # Separating prefix and title
    #
    def page_title(options = {})
      return "" if @page.title.blank?

      options = {
        prefix: "",
        suffix: "",
        separator: "",
      }.update(options)
      title_parts = [options[:prefix]]
      if response.status == 200
        title_parts << @page.title
      else
        title_parts << response.status
      end
      title_parts << options[:suffix]
      title_parts.reject(&:blank?).join(options[:separator]).html_safe
    end

    def meta_description
      @page.meta_description.presence || Language.current_root_page.try(:meta_description)
    end

    def meta_keywords
      @page.meta_keywords.presence || Language.current_root_page.try(:meta_keywords)
    end

    def meta_robots
      "#{@page.robot_index? ? "" : "no"}index, #{@page.robot_follow? ? "" : "no"}follow"
    end
  end
end
