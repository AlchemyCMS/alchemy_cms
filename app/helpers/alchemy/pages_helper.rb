module Alchemy
  module PagesHelper

    include Alchemy::BaseHelper
    include Alchemy::ElementsHelper

    def picture_essence_caption(content)
      content.try(:essence).try(:caption)
    end

    # Renders links to language root pages of all published languages.
    #
    # @option options linkname [String] ('name') Renders name/code of language, or I18n translation for code.
    # @option options show_title [Boolean] (true) Renders title attributes for the links.
    # @option options spacer [String] ('') Renders the passed spacer string. You can also overwrite the spacer partial: "alchemy/language_links/_spacer".
    # @option options reverse [Boolean] (false) Reverses the ordering of the links.
    #
    def language_links(options={})
      options = {
        linkname: 'name',
        show_title: true,
        spacer: '',
        reverse: false
      }.merge(options)
      languages = Language.published.with_language_root.order("name #{options[:reverse] ? 'DESC' : 'ASC'}")
      return nil if languages.count < 2
      render(
        partial: "alchemy/language_links/language",
        collection: languages,
        spacer_template: "alchemy/language_links/spacer",
        locals: {languages: languages, options: options}
      )
    end

    def language_switches(options={})
      ActiveSupport::Deprecation.warn("Used deprecated language_switches helper. Please use language_links instead.")
      language_links(options)
    end

    def language_switcher(options={})
      ActiveSupport::Deprecation.warn("Used deprecated language_switcher helper. Please use language_links instead.")
      language_links(options)
    end

    # Renders the layout from @page.page_layout. File resists in /app/views/page_layouts/_LAYOUT-NAME.html.erb
    def render_page_layout(options={})
      render :partial => "alchemy/page_layouts/#{@page.page_layout.downcase}"
    rescue ActionView::MissingTemplate
      warning("PageLayout: '#{@page.page_layout}' not found. Rendering standard page_layout.")
      render :partial => "alchemy/page_layouts/standard"
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
      render current_site
    rescue ActionView::MissingTemplate
      warning("Site layout for #{current_site.try(:name)} not found. Please run `rails g alchemy:site_layouts`")
      return ""
    end

    # Renders the navigation.
    #
    # It produces a html <ul><li></li></ul> structure with all necessary classes so you can produce every navigation the web uses today.
    # I.E. dropdown-navigations, simple mainnavigations or even complex nested ones.
    #
    # === En detail:
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
    # Then feel free to overwrite the partials (_renderer.html.erb and _link.html.erb) found in +views/navigation/+ or pass different partials via the options +:navigation_partial+ and +:navigation_link_partial+.
    #
    # === The options are:
    #
    #   :submenu => false                                     # Do you want a nested <ul> <li> structure for the deeper levels of your navigation, or not? Used to display the subnavigation within the mainnaviagtion. E.g. for dropdown menues.
    #   :all_sub_menues => false                              # Renders the whole page tree.
    #   :from_page => @root_page                              # Do you want to render a navigation from a different page then the current page? Then pass an Page instance or a Alchemy::PageLayout name as string.
    #   :spacer => nil                                        # A spacer for the entries can be passed. Simple string, or even a complex html structure. E.g: "<span class='spacer'>|</spacer>".
    #   :navigation_partial => "navigation/renderer"          # Pass a different partial to be taken for the navigation rendering.
    #   :navigation_link_partial => "navigation/link"         # Alchemy places an <a> html link in <li> tags. The tag automatically has an active css class if necessary. So styling is everything. But maybe you don't want this. So feel free to make you own partial and pass the filename here.
    #   :show_nonactive => false                              # Commonly Alchemy only displays the submenu of the active page (if :submenu => true). If you want to display all child pages then pass true (together with :submenu => true of course). E.g. for the popular css-driven dropdownmenues these days.
    #   :show_title => true                                   # For our beloved SEOs :). Appends a title attribute to all links and places the page.title content into it.
    #   :restricted_only => false                             # Render only restricted pages. I.E for members only navigations.
    #   :show_title => true                                   # Show a title on navigation links. Title attribute from page.
    #   :reverse => false                                     # Reverse the navigation
    #   :reverse_children => false                            # Reverse the nested children
    #   :deepness => nil                                      # Show only pages up to this depth.
    #
    # === Passing HTML classes and ids to the renderer
    #
    # A second hash can be passed as html_options to the navigation renderer partial.
    #
    # ==== Example:
    #
    #   <%= render_navigation({from_page => 'subnavi'}, {:class => 'navigation', :id => 'subnavigation'}) %>
    #
    def render_navigation(options = {}, html_options = {})
      options = {
        :submenu => false,
        :all_sub_menues => false,
        :from_page => @root_page || Page.language_root_for(session[:language_id]),
        :spacer => nil,
        :navigation_partial => "alchemy/navigation/renderer",
        :navigation_link_partial => "alchemy/navigation/link",
        :show_nonactive => false,
        :restricted_only => false,
        :show_title => true,
        :reverse => false,
        :reverse_children => false
      }.merge(options)
      page = page_or_find(options[:from_page])
      return nil if page.blank?
      pages = page.children.with_permissions_to(:see, :context => :alchemy_pages)
      pages = pages.restricted if options.delete(:restricted_only)
      if depth = options[:deepness]
        pages = pages.where("#{Page.table_name}.depth <= #{depth}")
      end
      if options[:reverse]
        pages.reverse!
      end
      render(
        options[:navigation_partial],
        :options => options,
        :pages => pages,
        :html_options => html_options
      )
    end

    # Renders navigation the children and all siblings of the given page (standard is the current page).
    #
    # Use this helper if you want to render the subnavigation independent from the mainnavigation. I.E. to place it in a different area on your website.
    #
    # This helper passes all its options to the the render_navigation helper.
    #
    # === Options:
    #
    #   :from_page => @page                              # The page to render the navigation from
    #   :submenu => true                                 # Shows the nested children
    #   :level => 2                                      # Normally there is no need to change the level parameter, just in a few special cases
    #
    def render_subnavigation(options = {})
      default_options = {
        :from_page => @page,
        :submenu => true,
        :level => 2
      }
      options = default_options.merge(options)
      if !options[:from_page].nil?
        while options[:from_page].level > options[:level] do
          options[:from_page] = options[:from_page].parent
        end
        render_navigation(options)
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
    #   :seperator => %(<span class="seperator">></span>)      # Maybe you don't want this seperator. Pass another one.
    #   :page => @page                                         # Pass a different Page instead of the default (@page).
    #   :without => nil                                        # Pass Page object or array of Pages that must not be displayed.
    #   :restricted_only => false                              # Pass boolean for displaying restricted pages only.
    #   :reverse => false                                      # Pass boolean for displaying breadcrumb in reversed reversed.
    #
    def render_breadcrumb(options={})
      options = {
        :seperator => %(<span class="seperator">&gt;</span>),
        :page => @page,
        :restricted_only => false,
        :reverse => false,
        :link_active_page => false
      }.merge(options)
      pages = breadcrumb(options[:page]).with_permissions_to(:see, :context => :alchemy_pages)
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
    #   :prefix => ""                 # Prefix
    #   :seperator => ""              # Seperating prefix and title
    #
    # === Webdevelopers
    #
    # Please use the render_meta_data() helper instead. There all important meta information gets rendered in one helper.
    # So you dont have to worry about anything.
    #
    def render_page_title(options={})
      return "" if @page.title.blank?
      default_options = {
        :prefix => "",
        :seperator => ""
      }
      default_options.update(options)
      [default_options[:prefix], response.status == 200 ? @page.title : response.status].join(default_options[:seperator])
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
        :prefix => "",
        :seperator => ""
      }
      options = default_options.merge(options)
      %(<title>#{render_page_title(options)}</title>).html_safe
    end

    # Renders a html <meta> tag for :name => "" and :content => ""
    #
    # === Webdevelopers:
    #
    # Please use the render_meta_data() helper. There all important meta information gets rendered in one helper.
    # So you dont have to worry about anything.
    #
    def render_meta_tag(options={})
      default_options = {
        :name => "",
        :default_language => "de",
        :content => ""
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
    # Then placing +render_meta_data(:title_prefix => "Company", :title_seperator => "-")+ into the <head> part of the +pages.html.erb+ layout produces:
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
        :title_prefix => "",
        :title_seperator => "",
        :default_lang => "de"
      }
      options = default_options.merge(options)
      #render meta description of the root page from language if the current meta description is empty
      if @page.meta_description.blank?
        description = Page.published.with_language(session[:language_id]).find_by_language_root(true).try(:meta_description)
      else
        description = @page.meta_description
      end
      #render meta keywords of the root page from language if the current meta keywords is empty
      if @page.meta_keywords.blank?
        keywords = Page.published.with_language(session[:language_id]).find_by_language_root(true).try(:meta_keywords)
      else
        keywords = @page.meta_keywords
      end
      robot = "#{@page.robot_index? ? "" : "no"}index, #{@page.robot_follow? ? "" : "no"}follow"
      meta_string = %(
        <meta charset="UTF-8">
        #{render_title_tag(:prefix => options[:title_prefix], :seperator => options[:title_seperator])}
        #{render_meta_tag(:name => "description", :content => description)}
        #{render_meta_tag(:name => "keywords", :content => keywords)}
        <meta name="created" content="#{@page.updated_at}">
        <meta name="robots" content="#{robot}">
      )
      if @page.contains_feed?
        meta_string += %(
          <link rel="alternate" type="application/rss+xml" title="RSS" href="#{show_alchemy_page_url(@page, :protocol => 'feed', :format => :rss)}">
        )
      end
      return meta_string.html_safe
    end

    # Renders the partial for the cell with the given name of the current page.
    # Cell partials are located in +app/views/cells/+ of your project.
    #
    # === Options are:
    #
    #   :from_page => Alchemy::Page     # Alchemy::Page object from which the elements are rendered from.
    #   :locals => Hash                 # Hash of variables that will be available in the partial. Example: {:user => var1, :product => var2}
    #
    def render_cell(name, options={})
      default_options = {
        :from_page => @page,
        :locals => {}
      }
      options = default_options.merge(options)
      cell = options[:from_page].cells.find_by_name(name)
      return "" if cell.blank?
      render :partial => "alchemy/cells/#{name}", :locals => {:cell => cell}.merge(options[:locals])
    end

    # Returns true or false if no elements are in the cell found by name.
    def cell_empty?(name)
      cell = @page.cells.find_by_name(name)
      return true if cell.blank?
      cell.elements.blank?
    end

    # Include this in your layout file to have element selection magic in the page edit preview window.
    def alchemy_preview_mode_code
      javascript_include_tag("alchemy/preview") if @preview_mode
    end

    # Renders a search form
    #
    # It queries the controller and then redirects to the search result page.
    #
    # === Example search results page layout
    #
    # Only performs the search if ferret is enabled in your +config/alchemy/config.yml+ and
    # a page is present that is flagged with +searchresults+ true.
    #
    #   # config/alchemy/page_layouts.yml
    #   - name: search
    #     searchresults: true # Flag as search result page
    #
    # === Note
    #
    # The search result page will not be cached.
    #
    # @option options html5 [Boolean] (true) Should the search form be of type search or not?
    # @option options class [String] (fulltext_search) The default css class of the form
    # @option options id [String] (search) The default css id of the form
    #
    def render_search_form(options={})
      default_options = {
        :html5 => false,
        :class => 'fulltext_search',
        :id => 'search'
      }
      render :partial => 'alchemy/search/form', :locals => {:options => default_options.merge(options), :search_result_page => find_search_result_page}
    end

    # Renders the search results partial within +app/views/alchemy/search/_results.html+
    #
    # @option options show_result_count [Boolean] (true) Should the count of results be displayed or not?
    # @option options show_heading [Boolean] (true) Should the heading be displayed or not?
    #
    def render_search_results(options={})
      default_options = {
        :show_result_count => true,
        :show_heading => true
      }
      render 'alchemy/search/results', :options => default_options.merge(options)
    end

    # Renders a menubar for logged in users that are visiting a page.
    def alchemy_menu_bar
      return if @preview_mode
      if permitted_to?(:edit, :alchemy_admin_pages)
        menu_bar_string = ""
        menu_bar_string += stylesheet_link_tag("alchemy/menubar")
        menu_bar_string += javascript_include_tag('alchemy/menubar')
        menu_bar_string += <<-STR
          <script type="text/javascript">
            try {
              Alchemy.loadAlchemyMenuBar({
                page_id: #{@page.id},
                route: '#{Alchemy::MountPoint.get}',
                locale: '#{current_user.language || ::I18n.default_locale}'
              });
            } catch(e) {
              if(console){console.log(e)}
            }
          </script>
        STR
        menu_bar_string.html_safe
      else
        nil
      end
    end

  end
end
