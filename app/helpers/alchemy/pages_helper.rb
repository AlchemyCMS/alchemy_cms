module Alchemy
  module PagesHelper

    include Alchemy::BaseHelper
    include Alchemy::ElementsHelper

    def render_classes(classes=[])
      s = classes.uniq.delete_if { |x| x.blank? }.join(" ")
      s.blank? ? "" : "class='#{s}'"
    end

    def picture_essence_caption(content)
      return "" if content.nil?
      return "" if content.essence.nil?
      content.essence.caption
    end

    # == Helper for rendering language switches
    #
    # Renders links to all public language root pages
    #
    # === Options:
    #
    #   :linkname => :name,
    #   :spacer => "",
    #   :link_to_public_child => configuration(:redirect_to_public_child),
    #   :link_to_page_with_layout => nil,
    #   :show_title => true,
    #   :reverse => false,
    #   :as_select_box => false,
    #   :show_flags => false
    #
    def language_switcher(options={})
      default_options = {
        :linkname => :name,
        :spacer => "",
        :link_to_public_child => configuration(:redirect_to_public_child),
        :link_to_page_with_layout => nil,
        :show_title => true,
        :reverse => false,
        :as_select_box => false,
        :show_flags => false
      }
      options = default_options.merge(options)
      if multi_language?
        language_links = []
        pages = (options[:link_to_public_child] == true) ? Page.from_current_site.language_roots : Page.from_current_site.public_language_roots
        return nil if (pages.blank? || pages.length == 1)
        pages.each_with_index do |page, i|
          if (options[:link_to_page_with_layout] != nil)
            page_found_by_layout = Page.from_current_site.where(:page_layout => options[:link_to_page_with_layout].to_s, :language_id => page.language_id).first
          end
          page = page_found_by_layout || page
          page = (options[:link_to_public_child] ? (page.first_public_child.blank? ? nil : page.first_public_child) : nil) if !page.public?
          if !page.blank?
            active = session[:language_id] == page.language.id
            linkname = page.language.label(options[:linkname])
            if options[:as_select_box]
              language_links << [linkname, show_page_url(:urlname => page.urlname, :lang => page.language.code)]
            else
              language_links << link_to(
                "#{content_tag(:span, '', :class => "flag") if options[:show_flags]}#{ content_tag(:span, linkname)}".html_safe,
                alchemy.show_page_path(:urlname => page.urlname, :lang => page.language.code),
                :class => "#{(active ? 'active ' : nil)}#{page.language.code} #{(i == 0) ? 'first' : (i==pages.length-1) ? 'last' : nil}",
                :title => options[:show_title] ? Alchemy::I18n.t("alchemy.language_links.#{page.language.code}.title", :default => page.language.name) : nil
              )
            end
          end
          # when last iteration and we have just one language_link,
          # we dont need to render it.
          if (i==pages.length-1) && language_links.length == 1
            return nil
          end
        end
        return nil if language_links.empty? || language_links.length == 1
        language_links.reverse! if options[:reverse]
        if options[:as_select_box]
          return select_tag(
            'language',
            options_for_select(
              language_links,
              show_page_url(:urlname => @page.urlname, :lang => @page.language.code)
            ),
            :onchange => "window.location=this.value"
          )
        else
          raw(language_links.join(options[:spacer]))
        end
      else
        nil
      end
    end
    alias_method :language_switches, :language_switcher

    # Renders the layout from @page.page_layout. File resists in /app/views/page_layouts/_LAYOUT-NAME.html.erb
    def render_page_layout(options={})
      render :partial => "alchemy/page_layouts/#{@page.page_layout.downcase}"
    rescue ActionView::MissingTemplate
      warning("PageLayout: '#{@page.page_layout}' not found. Rendering standard page_layout.")
      render :partial => "alchemy/page_layouts/standard"
    end

    def sitename_from_header_page
      header_page = Page.find_by_page_layout_and_layoutpage('layout_header', true)
      return "" if header_page.nil?
      page_title = header_page.elements.find_by_name('sitename')
      return "" if page_title.nil?
      page_title.ingredient('name')
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
    #   :spacer => ""                                         # Yeah even a spacer for the entries can be passed. Simple string, or even a complex html structure. E.g: "<span class='spacer'>|</spacer>". Only your imagination is the limit. And the W3C of course :)
    #   :navigation_partial => "navigation/renderer"          # Pass a different partial to be taken for the navigation rendering. CAUTION: Only for the advanced Alchemy webdevelopers. The standard partial takes care of nearly everything. But maybe you are an adventures one ^_^
    #   :navigation_link_partial => "navigation/link"         # Alchemy places an <a> html link in <li> tags. The tag automatically has an active css class if necessary. So styling is everything. But maybe you don't want this. So feel free to make you own partial and pass the filename here.
    #   :show_nonactive => false                              # Commonly Alchemy only displays the submenu of the active page (if :submenu => true). If you want to display all child pages then pass true (together with :submenu => true of course). E.g. for the popular css-driven dropdownmenues these days.
    #   :show_title => true                                   # For our beloved SEOs :). Appends a title attribute to all links and places the page.title content into it.
    #   :restricted_only => nil                               # Render only restricted pages.
    #   :show_title => true                                   # Show a title on navigation links. Title attribute from page.
    #   :reverse => false                                     # Reverse the navigation
    #   :reverse_children => false                            # Reverse the nested children
    #
    # === Passing HTML classes and ids to the renderer
    #
    # A second hash will be passed as html_options to the navigation renderer partial.
    #
    # ==== Example:
    #
    #   <%= render_navigation({from_page => 'subnavi'}, {:class => 'navigation', :id => 'subnavigation'}) %>
    #
    def render_navigation(options = {}, html_options = {})
      default_options = {
        :submenu => false,
        :all_sub_menues => false,
        :from_page => @root_page || Page.language_root_for(session[:language_id]),
        :spacer => "",
        :navigation_partial => "alchemy/navigation/renderer",
        :navigation_link_partial => "alchemy/navigation/link",
        :show_nonactive => false,
        :restricted_only => nil,
        :show_title => true,
        :reverse => false,
        :reverse_children => false
      }
      options = default_options.merge(options)
      if options[:from_page].is_a?(String)
        page = Page.find_by_page_layout_and_language_id(options[:from_page], session[:language_id])
      else
        page = options[:from_page]
      end
      if page.blank?
        warning("No Page found for #{options[:from_page]}")
        return ""
      end
      conditions = {
        :parent_id => page.id,
        :restricted => options[:restricted_only] || false,
        :visible => true
      }
      if options[:restricted_only].nil?
        conditions.delete(:restricted)
      end
      pages = Page.where(conditions).order("lft ASC")
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
    #   :without => nil                                        # Pass Pageobject or array of Pages that must not be displayed.
    #   :public_only => false                                  # Pass boolean for displaying published pages only.
    #   :visible_only => true                                  # Pass boolean for displaying (in navigation) visible pages only.
    #   :restricted_only => false                              # Pass boolean for displaying restricted pages only.
    #   :reverse => false                                      # Pass boolean for displaying reversed breadcrumb.
    #
    def render_breadcrumb(options={})
      default_options = {
        :seperator => %(<span class="seperator">&gt;</span>),
        :page => @page,
        :without => nil,
        :public_only => true,
        :visible_only => true,
        :restricted_only => false,
        :reverse => false,
        :link_active_page => false
      }
      options = default_options.merge(options)
      pages = breadcrumb(options[:page])
      pages.delete(Page.root)
      unless options[:without].nil?
        unless options[:without].class == Array
          pages.delete(options[:without])
        else
          pages = pages - options[:without]
        end
      end
      if options[:visible_only]
        pages.reject! { |p| !p.visible? }
      end
      if options[:public_only]
        pages.reject! { |p| !p.public? }
      end
      if options[:restricted_only]
        pages.reject! { |p| !p.restricted? }
      end
      if options[:reverse]
        pages.reverse!
      end
      bc = []
      pages.each do |page|
        css_class = page.name == @page.name ? "active" : nil
        if page == pages.last
          css_class = css_class.blank? ? "last" : [css_class, "last"].join(" ")
        elsif page == pages.first
          css_class = css_class.blank? ? "first" : [css_class, "first"].join(" ")
        end
        if !options[:link_active_page] && page.name == @page.name
          bc << content_tag(:span, h(page.name), :class => css_class)
        else
          bc << link_to(h(page.name), show_alchemy_page_path(page), :class => css_class, :title => page.title)
        end
      end
      bc.join(options[:seperator]).html_safe
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
                route: '#{Alchemy.mount_point}',
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
