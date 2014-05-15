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
    def language_links(options={})
      options = {
        linkname: 'name',
        show_title: true,
        spacer: '',
        reverse: false
      }.merge(options)
      languages = Language.published.with_root_page.order("name #{options[:reverse] ? 'DESC' : 'ASC'}")
      return nil if languages.count < 2
      render(
        partial: "alchemy/language_links/language",
        collection: languages,
        spacer_template: "alchemy/language_links/spacer",
        locals: {languages: languages, options: options}
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
      render 'alchemy/page_layouts/standard', page: @page
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
    def render_site_layout
      render current_alchemy_site
    rescue ActionView::MissingTemplate
      warning("Site layout for #{current_alchemy_site.try(:name)} not found. Please run `rails g alchemy:site_layouts`")
      return ""
    end

    # Renders the navigation.
    #
    # It produces a html <ul><li></li></ul> structure with all necessary classes so you can produce every navigation the web uses today.
    # I.E. dropdown-navigations, simple mainnavigations or even complex nested ones.
    #
    # === HTML output:
    #
    #   <ul class="navigation level_1">
    #     <li class="first home"><a href="/home" class="active" title="Homepage" lang="en" data-page-id="1">Homepage</a></li>
    #     <li class="contact"><a href="/contact" title="Contact" lang="en" data-page-id="2">Contact</a></li>
    #     <li class="last imprint"><a href="/imprint" title="Imprint" lang="en" data-page-id="3">Imprint</a></li>
    #   </ul>
    #
    # As you can see: Everything you need.
    #
    # Not pleased with the way Alchemy produces the navigation structure?
    #
    # Then feel free to overwrite the partials (_renderer.html.erb and _link.html.erb) found in +views/navigation/+ or pass different partials via the options +:navigation_partial+ and +:navigation_link_partial+.
    #
    # === Passing HTML classes and ids to the renderer
    #
    # A second hash can be passed as html_options to the navigation renderer partial.
    #
    # ==== Example:
    #
    #   <%= render_navigation({from_page: 'subnavi'}, {class: 'navigation', id: 'subnavigation'}) %>
    #
    #
    # @option options submenu [Boolean] (false)
    #   Do you want a nested <ul> <li> structure for the deeper levels of your navigation, or not?
    #   Used to display the subnavigation within the mainnaviagtion. I.e. for dropdown menues.
    #
    # @option options all_sub_menues [Boolean] (false)
    #   Renders the whole page tree.
    #
    # @option options from_page [Alchemy::Page] (@root_page)
    #   Do you want to render a navigation from a different page then the current page?
    #   Then pass an Page instance or a Alchemy::PageLayout name as string.
    #
    # @option options spacer [String] (nil)
    #   A spacer for the entries can be passed.
    #   Simple string, or even a complex html structure.
    #   I.e: "<span class='spacer'>|</spacer>".
    #
    # @option options navigation_partial [String] ("navigation/renderer")
    #   Pass a different partial to be taken for the navigation rendering.
    #   Alternatively you could override the +app/views/alchemy/navigation/renderer+ partial in your app.
    #
    # @option options navigation_link_partial [String] ("navigation/link")
    #   Alchemy places an <a> html link in <li> tags.
    #   The tag automatically has an active css class if necessary.
    #   So styling is everything. But maybe you don't want this.
    #   So feel free to make you own partial and pass the filename here.
    #   Alternatively you could override the +app/views/alchemy/navigation/link+ partial in your app.
    #
    # @option options show_nonactive [Boolean] (false)
    #   Commonly Alchemy only displays the submenu of the active page (if submenu: true).
    #   If you want to display all child pages then pass true (together with submenu: true of course).
    #   I.e. for css-driven drop down menues.
    #
    # @option options show_title [Boolean] (true)
    #   For our beloved SEOs :)
    #   Appends a title attribute to all links and places the +page.title+ content into it.
    #
    # @option options restricted_only [Boolean] (false)
    #   Render only restricted pages. I.E for members only navigations.
    #
    # @option options reverse [Boolean] (false)
    #   Reverse the output of the pages
    #
    # @option options reverse_children [Boolean] (false)
    #   Like reverse option, but only reverse the children of the first level
    #
    # @option options deepness [Fixnum] (nil)
    #   Show only pages up to this depth.
    #
    def render_navigation(options = {}, html_options = {})
      options = {
        submenu: false,
        all_sub_menues: false,
        from_page: @root_page || Language.current_root_page,
        spacer: nil,
        navigation_partial: 'alchemy/navigation/renderer',
        navigation_link_partial: 'alchemy/navigation/link',
        show_nonactive: false,
        restricted_only: false,
        show_title: true,
        reverse: false,
        reverse_children: false
      }.merge(options)
      page = page_or_find(options[:from_page])
      return nil if page.blank?
      pages = page.children.accessible_by(current_ability, :see)
      pages = pages.restricted if options.delete(:restricted_only)
      if depth = options[:deepness]
        pages = pages.where("#{Page.table_name}.depth <= #{depth}")
      end
      if options[:reverse]
        pages.reverse!
      end
      render options[:navigation_partial],
        options: options,
        pages: pages,
        html_options: html_options
    end

    # Renders navigation the children and all siblings of the given page (standard is the current page).
    #
    # Use this helper if you want to render the subnavigation independent from the mainnavigation. I.E. to place it in a different area on your website.
    #
    # This helper passes all its options to the the render_navigation helper.
    #
    # === Options:
    #
    #   from_page: @page                              # The page to render the navigation from
    #   submenu: true                                 # Shows the nested children
    #   level: 2                                      # Normally there is no need to change the level parameter, just in a few special cases
    #
    def render_subnavigation(options = {}, html_options = {})
      default_options = {
        from_page: @page,
        submenu: true,
        level: 2
      }
      options = default_options.merge(options)
      if !options[:from_page].nil?
        while options[:from_page].level > options[:level] do
          options[:from_page] = options[:from_page].parent
        end
        render_navigation(options, html_options)
      else
        return nil
      end
    end

    # Returns true if page is in the active branch
    def page_active?(page)
      @breadcrumb ||= breadcrumb(@page)
      @breadcrumb.include?(page)
    end

    # Returns +'active'+ if the given external page is in the current url path or +nil+.
    def external_page_css_class(page)
      return nil if !page.redirects_to_external?
      request.path.split('/').delete_if(&:blank?).first == page.urlname.gsub(/^\//, '') ? 'active' : nil
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
    def render_breadcrumb(options={})
      options = {
        separator: %(<span class="separator">&gt;</span>),
        page: @page,
        restricted_only: false,
        reverse: false,
        link_active_page: false
      }.merge(options)
      pages = breadcrumb(options[:page]).accessible_by(current_ability, :see)
      pages = pages.restricted if options.delete(:restricted_only)
      pages.to_a.reverse! if options[:reverse]
      if options[:without].present?
        if options[:without].class == Array
          pages = pages.to_a - options[:without]
        else
          pages.to_a.delete(options[:without])
        end
      end
      render(
        partial: 'alchemy/breadcrumb/page',
        collection: pages,
        spacer_template: 'alchemy/breadcrumb/spacer',
        locals: {pages: pages, options: options}
      )
    end

    # Returns current page title
    #
    # === Options:
    #
    #   prefix: ""                 # Prefix
    #   separator: ""              # Separating prefix and title
    #
    # === Webdevelopers
    #
    # Please use the render_meta_data() helper instead. There all important meta information gets rendered in one helper.
    # So you dont have to worry about anything.
    #
    def render_page_title(options = {})
      return "" if @page.title.blank?
      options = {
        prefix: "",
        separator: ""
      }.update(options)
      title_parts = [options[:prefix]]
      if response.status == 200
        title_parts << @page.title
      else
        title_parts << response.status
      end
      title_parts.join(options[:separator])
    end

    # Returns a complete html <title> tag for the <head> part of the html document.
    #
    # === Webdevelopers:
    #
    # Please use the render_meta_data() helper. There all important meta information gets rendered in one helper.
    # So you dont have to worry about anything.
    #
    def render_title_tag(options={})
      default_options = {
        prefix: "",
        separator: ""
      }
      options = default_options.merge(options)
      %(<title>#{render_page_title(options)}</title>).html_safe
    end

    # Renders a html <meta> tag for name: "" and content: ""
    #
    # === Webdevelopers:
    #
    # Please use the render_meta_data() helper. There all important meta information gets rendered in one helper.
    # So you dont have to worry about anything.
    #
    def render_meta_tag(options={})
      default_options = {
        name: "",
        default_language: "de",
        content: ""
      }
      options = default_options.merge(options)
      lang = (@page.language.blank? ? options[:default_language] : @page.language.code)
      %(<meta name="#{options[:name]}" content="#{options[:content]}" lang="#{lang}">).html_safe
    end

    # This helper takes care of all important meta tags for your page.
    #
    # The meta data is been taken from the @page.title, @page.meta_description, @page.meta_keywords, @page.updated_at and @page.language database entries managed by the Alchemy user via the Alchemy cockpit.
    #
    # Assume that the user has entered following data into the Alchemy cockpit of the Page "home" and that the user wants that the searchengine (aka. google) robot should index the page and should follow all links on this page:
    #
    # Title = Homepage
    # Description = Your page description
    # Keywords: cms, ruby, rubyonrails, rails, software, development, html, javascript, ajax
    #
    # Then placing +render_meta_data(title_prefix: "Company", title_separator: "-")+ into the <head> part of the +pages.html.erb+ layout produces:
    #
    #   <meta charset="UTF-8">
    #   <title>Company - #{@page.title}</title>
    #   <meta name="description" content="Your page description">
    #   <meta name="keywords" content="cms, ruby, rubyonrails, rails, software, development, html, javascript, ajax">
    #   <meta name="created" content="Tue Dec 16 10:21:26 +0100 2008">
    #   <meta name="robots" content="index, follow">
    #
    def render_meta_data options={}
      if @page.blank?
        warning("No Page found!")
        return nil
      end
      default_options = {
        title_prefix: "",
        title_separator: "",
        default_lang: "de"
      }
      options = default_options.merge(options)
      # render meta description of the root page from language if the current meta description is empty
      if @page.meta_description.blank?
        description = Language.current.pages.published.language_roots.try(:meta_description)
      else
        description = @page.meta_description
      end
      # render meta keywords of the root page from language if the current meta keywords is empty
      if @page.meta_keywords.blank?
        keywords = Language.current.pages.published.language_roots.try(:meta_keywords)
      else
        keywords = @page.meta_keywords
      end
      robot = "#{@page.robot_index? ? "" : "no"}index, #{@page.robot_follow? ? "" : "no"}follow"
      meta_string = %(
        <meta charset="UTF-8">
        #{render_title_tag(prefix: options[:title_prefix], separator: options[:title_separator])}
        #{render_meta_tag(name: "description", content: description)}
        #{render_meta_tag(name: "keywords", content: keywords)}
        <meta name="created" content="#{@page.updated_at}">
        <meta name="robots" content="#{robot}">
      )
      if @page.contains_feed?
        meta_string += %(
          <link rel="alternate" type="application/rss+xml" title="RSS" href="#{show_alchemy_page_url(@page, format: :rss)}">
        )
      end
      return meta_string.html_safe
    end

    # Renders the partial for the cell with the given name of the current page.
    # Cell partials are located in +app/views/cells/+ of your project.
    #
    # === Options are:
    #
    #   from_page: Alchemy::Page     # Alchemy::Page object from which the elements are rendered from.
    #   locals: Hash                 # Hash of variables that will be available in the partial. Example: {user: var1, product: var2}
    #
    def render_cell(name, options={})
      default_options = {
        from_page: @page,
        locals: {}
      }
      options = default_options.merge(options)
      cell = options[:from_page].cells.find_by_name(name)
      return "" if cell.blank?
      render partial: "alchemy/cells/#{name}", locals: {cell: cell}.merge(options[:locals])
    end

    # Returns true or false if no elements are in the cell found by name.
    def cell_empty?(name)
      cell = @page.cells.find_by_name(name)
      return true if cell.blank?
      cell.elements.blank?
    end

    # Include this in your layout file to have element selection magic in the page edit preview window.
    def alchemy_preview_mode_code
      if @preview_mode
        output = javascript_tag("Alchemy = { locale: '#{session[:alchemy_locale]}' };")
        output += javascript_include_tag("alchemy/preview")
      end
    end

  end
end
