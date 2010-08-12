# Copyright: 2007-2010 Thomas von Deyen and Carsten Fregin
# Author:    Thomas von Deyen
# Date:      02.06.2010
# License:   GPL
# All methods (helpers) in this helper are used by Alchemy to render elements, contents and layouts on the Page.
# You can call this helper the most important part of Alchemy. This helper is Alchemy, actually :)
#
# TODO: list all important infos here.
# 
# Most Important Infos:
# ---
#
# 1. The most important helpers for webdevelopers are the render_navigation(), render_elements() and the render_page_layout() helpers.
# 2. The currently displayed page can be accessed with the current_page() helper. This is actually the page found via Page.find_by_name("some_url_name") page
# 3. All important meta data from current_page will be rendered via the render_meta_data() helper.

module ApplicationHelper

  include FastGettext::Translation

  def configuration(name)
    return Alchemy::Configuration.parameter(name)
  end

  # Did not know of the truncate helepr form rails at this time.
  # The way is to pass this to truncate....
  def shorten(text, length)
    if text.length <= length - 1
      text
    else
      text[0..length - 1] + "..."
    end
  end
  
  def render_editor(element)
    render_element(element, :editor)
  end

  def get_content(element, position)
    return element.contents[position - 1]
  end

  # Renders all elements from current_page.
  # ---
  # == Options are:
  # :only => []                 A list of element names to be rendered only. Very usefull if you want to render a specific element type in a special html part (e.g.. <div>) of your page and all other elements in another part.
  # :except => []               A list of element names to be rendered. The opposite of the only option.
  # :from_page                  The Page.page_layout string from which the elements are rendered from, or you even pass a Page object.
  # :count                      The amount of elements to be rendered (beginns with first element found)
  # :fallback => {:for => 'ELEMENT_NAME', :with => 'ELEMENT_NAME', :from => 'PAGE_LAYOUT'} when no element from this name is found on page, then use this element from that page
  # 
  # This helper also stores all pages where elements gets rendered on, so we can sweep them later if caching expires!
  def render_elements(options = {})
    default_options = {
      :except => [],
      :only => [],
      :from_page => "",
      :count => nil,
      :render_format => "html",
      :fallback => nil
    }
    options = default_options.merge(options)
    if options[:from_page].blank?
      page = current_page
    else
      if options[:from_page].class == Page
        page = options[:from_page]
      else
        page = Page.find_by_page_layout_and_language(options[:from_page], session[:language])
      end
    end
    if page.blank?
      logger.warn %(\n
        ++++ WARNING: Page is nil in render_elements() helper ++++
        Maybe options[:from_page] references to a page that is not created yet?\n
      )
      return ""
    else
      show_non_public = configuration(:cache_pages) ? false : defined?(current_user)
      all_elements = page.find_elements(options, show_non_public)
      element_string = ""
      if options[:fallback]
        unless all_elements.detect { |e| e.name == options[:fallback][:for] }
          from = Page.find_by_page_layout(options[:fallback][:from])
          all_elements += from.elements.find_all_by_name(options[:fallback][:with].blank? ? options[:fallback][:for] : options[:fallback][:with])
        end
      end
      all_elements.each do |element|
        element_string += render_element(element, :view, options)
      end
      element_string
    end
  end

  # This helper renders the Element partial for either the view or the editor part.
  # Generate element partials with ./script/generate elements
  def render_element(element, part = :view, options = {})
    if element.blank?
      logger.warn %(\n
        ++++ WARNING: Element is nil.\n
        Usage: render_element(element, part, options = {})\n
      )
      render :partial => "elements/#{part}_not_found", :locals => {:name => 'nil'}
    else
      default_options = {
        :shorten_to => nil,
        :render_format => "html"
      }
      options = default_options.merge(options)
      element.store_page(current_page) if part == :view
      path1 = "#{RAILS_ROOT}/app/views/elements/"
      path2 = "#{RAILS_ROOT}/vendor/plugins/alchemy/app/views/elements/"
      partial_name = "_#{element.name.underscore}_#{part}.html.erb"
      if File.exists?(path1 + partial_name) || File.exists?(path2 + partial_name)
        if @preview_mode
          render(
            :partial => 'admin/elements/element_preview',
            :locals => {
              :element => element,
              :options => options
            }
          )
        else
          render(
            :partial => "elements/#{element.name.underscore}_#{part}.#{options[:render_format]}.erb",
            :locals => {
              :element => element,
              :options => options
            }
          )
        end
      else
        logger.warn %(\n
          ++++ WARNING: Element #{part} partial not found for #{element.name}.\n
          Looking for #{partial_name}, but not found
          neither in #{path1}
          nor in #{path2}
          Use ./script/generate elements to generate them.
          Maybe you still have old style partial names? (like .rhtml). Then please rename them in .html.erb!\n
        )
        render :partial => "elements/#{part}_not_found", :locals => {:name => element.name, :error => "Element #{part} partial not found. Use ./script/generate elements to generate them."}
      end
    end
  end

  # DEPRICATED: It is useless to render a helper that only renders a partial.
  # Unless it is something the website producer uses. But this is not the case here.
  def render_element_head element
    render :partial => "elements/partials/element_head", :locals => {:element_head => element}
  end

  # Renders the Content partial that is given (:editor, or :view).
  # You can pass several options that are used by the different contents.
  #
  # For the view partial:
  # :image_size => "111x93"                        Used by EssencePicture to render the image via RMagick to that size.
  # :css_class => ""                               This css class gets attached to the content view.
  # :date_format => "Am %d. %m. %Y, um %H:%Mh"     Espacially fot the EssenceDate. See Date.strftime for date formatting.
  # :caption => true                               Pass true to enable that the EssencePicture.caption value gets rendered.
  # :blank_value => ""                             Pass a String that gets rendered if the content.essence is blank.
  #
  # For the editor partial:
  # :css_class => ""                               This css class gets attached to the content editor.
  # :last_image_deletable => false                 Pass true to enable that the last image of an imagecollection (e.g. image gallery) is deletable.
  def render_essence(content, part = :view, options = {})
    if content.nil?
      logger.warn %(\n
        ++++ WARNING: Content is nil!\n
        Usage: render_essence(content, part, options = {})\n
      )
      return part == :view ? "" : "<p class=\"content_editor_error\">" + _("content_not_found") + "</p>"
    elsif content.essence.nil?
      logger.warn %(\n
        ++++ WARNING: Content.essence is nil!\n
        Please delete the element and create it again!
      )
      return part == :view ? "" : "<p class=\"content_editor_error\">" + _("content_essence_not_found") + "</p>"
    end
    defaults = {
      :for_editor => {
        :as => 'text_field',
        :css_class => 'long'
      },
      :for_view => {
        :image_size => "120x90",
        :css_class => "",
        :date_format => "%d. %m. %Y, %H:%Mh",
        :caption => true,
        :blank_value => ""
      },
      :render_format => "html"
    }
    options_for_partial = defaults[('for_' + part.to_s).to_sym].merge(options[('for_' + part.to_s).to_sym])
    options = options.merge(defaults)
    render(
      :partial => "essences/#{content.essence.class.name.underscore}_#{part.to_s}.#{options[:render_format]}.erb",
      :locals => {
        :content => content,
        :options => options_for_partial
      }
    )
  end

  # Renders the Content editor partial from the given Content.
  # For options see -> render_essence
  def render_essence_editor(content, options = {})
    render_essence(content, :editor, :for_editor => options)
  end

  # Renders the Content view partial from the given Content.
  # For options see -> render_essence
  def render_essence_view(content, options = {})
    render_essence(content, :view, :for_view => options)
  end

  # Renders the Content editor partial from the given Element for the essence_type (e.g. EssenceRichtext).
  # For multiple contents of same kind inside one molecue just pass a position so that will be rendered.
  # Otherwise the first content found for this type will be rendered.
  # For options see -> render_essence
  def render_essence_editor_by_type(element, type, position = nil, options = {})
    if element.blank?
      logger.warn %(\n
        ++++ WARNING: Element is nil!\n
        Usage: render_essence_view(element, position, options = {})\n
      )
      return "<p class='element_error'>" + _("no_element_given") + "</p>"
    end
    if position.nil?
      content = element.content_by_type(type)
    else
      content = element.contents.find_by_essence_type_and_position(type, position)
    end
    render_essence(content, :editor, :for_editor => options)
  end

  # Renders the Content view partial from the given Element for the essence_type (e.g. EssenceRichtext).
  # For multiple contents of same kind inside one molecue just pass a position so that will be rendered.
  # Otherwise the first content found for this type will be rendered.
  # For options see -> render_essence
  def render_essence_view_by_type(element, type, position, options = {})
    if element.blank?
      logger.warn %(\n
        ++++ WARNING: Element is nil!\n
        Usage: render_essence_view(element, position, options = {})\n
      )
      return ""
    end
    if position.nil?
      content = element.content_by_type(type)
    else
      content = element.contents.find_by_essence_type_and_position(type, position)
    end
    render_essence(content, :view, :for_view => options)
  end

  # Renders the Content view partial from the given Element by position (e.g. 1).
  # For options see -> render_essence
  def render_essence_view_by_position(element, position, options = {})
    if element.blank?
      logger.warn %(\n
        ++++ WARNING: Element is nil!\n
        Usage: render_essence_view_by_position(element, position, options = {})\n
      )
      return ""
    end
    content = element.contents.find_by_position(position)
    render_essence(content, :view, :for_view => options)
  end

  # Renders the Content editor partial from the given Element by position (e.g. 1).
  # For options see -> render_essence
  def render_essence_editor_by_position(element, position, options = {})
    if element.blank?
      logger.warn %(\n
        ++++ WARNING: Element is nil!\n
        Usage: render_essence_view_by_position(element, position, options = {})\n
      )
      return ""
    end
    content = element.contents.find_by_position(position)
    render_essence(content, :editor, :for_editor => options)
  end

  # Renders the Content editor partial found in views/contents/ for the content with name inside the passed Element.
  # For options see -> render_essence
  def render_essence_editor_by_name(element, name, options = {})
    if element.blank?
      logger.warn %(\n
        ++++ WARNING: Element is nil!\n
        Usage: render_essence_view(element, position, options = {})\n
      )
      return "<p class='element_error'>" + _("no_element_given") + "</p>"
    end
    content = element.content_by_name(name)
    render_essence(content, :editor, :for_editor => options)
  end

  # Renders the Content view partial from the passed Element for passed content name.
  # For options see -> render_essence
  def render_essence_view_by_name(element, name, options = {})
    if element.blank?
      logger.warn %(\n
        ++++ WARNING: Element is nil!\n
        Usage: render_essence_view(element, position, options = {})\n
      )
      return ""
    end
    content = element.content_by_name(name)
    render_essence(content, :view, :for_view => options)
  end

  # Returns current_page.title
  #
  # The options are:
  # :prefix => ""
  # :seperator => "|"
  #
  # == Webdevelopers:
  # Please use the render_meta_data() helper. There all important meta information gets rendered in one helper.
  # So you dont have to worry about anything.
  def render_page_title options={}
    default_options = {
      :prefix => "",
      :seperator => "|"
    }
    default_options.update(options)
    unless current_page.title.blank?
      h("#{default_options[:prefix]} #{default_options[:seperator]} #{current_page.title}")
    else
      h("")
    end
  end

  # Returns a complete html <title> tag for the <head> part of the html document.
  #
  # == Webdevelopers:
  # Please use the render_meta_data() helper. There all important meta information gets rendered in one helper.
  # So you dont have to worry about anything.
  def render_title_tag options={}
    default_options = {
      :prefix => "",
      :seperator => "|"
    }
    options = default_options.merge(options)
    title = render_page_title(options)
    %(<title>#{title}</title>)
  end

  # Renders a html <meta> tag for :name => "" and :content => ""
  #
  # == Webdevelopers:
  # Please use the render_meta_data() helper. There all important meta information gets rendered in one helper.
  # So you dont have to worry about anything.
  def render_meta_tag(options={})
    default_options = {
      :name => "",
      :default_language => "de",
      :content => ""
    }
    options = default_options.merge(options)
    lang = (current_page.language.blank? ? options[:default_language] : current_page.language)
    %(<meta name="#{options[:name]}" content="#{options[:content]}" lang="#{lang}" xml:lang="#{lang}" />)
  end

  # Renders a html <meta http-equiv="Content-Language" content="#{lang}" /> for current_page.language.
  #
  # == Webdevelopers:
  # Please use the render_meta_data() helper. There all important meta information gets rendered in one helper.
  # So you dont have to worry about anything.
  def render_meta_content_language_tag(options={})
    default_options = {
      :default_language => "de"
    }
    options = default_options.merge(options)
    lang = (current_page.language.blank? ? options[:default_language] : current_page.language)
    %(<meta http-equiv="Content-Language" content="#{lang}" />)
  end

  # = This helper takes care of all important meta tags for your current_page.
  # ---
  # The meta data is been taken from the current_page.title, current_page.meta_description, current_page.meta_keywords, current_page.updated_at and current_page.language database entries managed by the Alchemy user via the Alchemy cockpit.
  #
  # Assume that the user has entered following data into the Alchemy cockpit of the Page "home" and that the user wants that the searchengine (aka. google) robot should index the page and should follow all links on this page:
  #
  # Title = Homepage
  # Description = Your page description
  # Keywords: cms, ruby, rubyonrails, rails, software, development, html, javascript, ajax
  # 
  # Then placing render_meta_data(:title_prefix => "company", :title_seperator => "::") into the <head> part of the pages.html.erb layout produces:
  #
  # <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  # <meta http-equiv="Content-Language" content="de" />
  # <title>Company :: #{current_page.title}</title>
  # <meta name="description" content="Your page description" />
  # <meta name="keywords" content="cms, ruby, rubyonrails, rails, software, development, html, javascript, ajax" />
  # <meta name="generator" content="Alchemy VERSION" />
  # <meta name="date" content="Tue Dec 16 10:21:26 +0100 2008" />
  # <meta name="robots" content="index, follow" />
  # 
  def render_meta_data options={}
    default_options = {
      :title_prefix => "",
      :title_seperator => "|",
      :default_lang => "de"
    }
    options = default_options.merge(options)
    #render meta description of the root page from language if the current meta description is empty
    if current_page.meta_description.blank?
      description = Page.language_root(session[:language]).meta_description
    else
      description = current_page.meta_description
    end
    #render meta keywords of the root page from language if the current meta keywords is empty
    if current_page.meta_keywords.blank?
      keywords = Page.language_root(session[:language]).meta_keywords
    else
      keywords = current_page.meta_keywords
    end
    robot = "#{current_page.robot_index? ? "" : "no"}index, #{current_page.robot_follow? ? "" : "no"}follow"
    meta_string = %(
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      #{render_meta_content_language_tag}
      #{render_title_tag( :prefix => options[:title_prefix], :seperator => options[:title_seperator])}
      #{render_meta_tag( :name => "description", :content => description)}
      #{render_meta_tag( :name => "keywords", :content => keywords)}
      <meta name="generator" content="Alchemy #{configuration(:alchemy_version)}" />
      <meta name="date" content="#{current_page.updated_at}" />
      <meta name="robots" content="#{robot}" />
    )
    if @page.contains_feed?
    meta_string += %(
      <link rel="alternate" type="application/rss+xml" title="RSS" href="#{multi_language? ? show_page_with_language_url(:protocol => 'feed', :urlname => @page.urlname, :lang => session[:language], :format => :rss) : show_page_url(:protocol => 'feed', :urlname => @page.urlname, :format => :rss)}" />
    )
    end
    return meta_string
  end

  # Returns an array of all pages in the same branch from current. Used internally to find the active page in navigations.
  def breadcrumb current
    return [] if current.nil?
    result = Array.new
    result << current
    while current = current.parent
      result << current
    end
    return result.reverse
  end

  # Returns a html string for a linked breadcrump to current_page.
  # == Options:
  # :seperator => %(<span class="seperator">></span>)      Maybe you don't want this seperator. Pass another one.
  # :page => current_page                                  Pass a different Page instead of the default current_page.
  # :without => nil                                        Pass Page object that should not be displayed inside the breadcrumb.
  def render_breadcrumb(options={})
    default_options = {
      :seperator => %(<span class="seperator">></span>),
      :page => current_page,
      :without => nil
    }
    options = default_options.merge(options)
    bc = ""
    pages = breadcrumb(options[:page])
    pages.delete(Page.root)
    unless options[:without].nil?
      unless options[:without].class == Array
        pages.delete(options[:without])
      else
        pages = pages - options[:without]
      end
    end
    pages.each do |page|
      if page.name == current_page.name
        css_class = "active"
      elsif page == pages.last
        css_class = "last"
      elsif page == pages.first
        css_class = "first"
      end
      if (page == Page.language_root(session[:language]))
        if configuration(:redirect_index)
          url = show_page_url(:urlname => page.urlname)
        else
          url = index_url
        end
      else
        url = show_page_url(:urlname => page.urlname)
      end
      bc << link_to( h(page.name), url, :class => css_class, :title => page.title )
      unless page == pages.last
        bc << options[:seperator]
      end
    end
    bc
  end

  # returns true if page is in the active branch
  def page_active? page
    @breadcrumb ||= breadcrumb(@page)
    @breadcrumb.include? page
  end

  # = This helper renders the navigation.
  #
  # It produces a html <ul><li></li></ul> structure with all necessary classes and ids so you can produce nearly every navigation the web uses today.
  # E.G. dropdown-navigations, simple mainnavigations or even complex nested ones.
  # ---
  # == En detail:
  # 
  # <ul>
  #   <li class="first" id="home"><a href="home" class="active">Homepage</a></li>
  #   <li id="contact"><a href="contact">Contact</a></li>
  #   <li class="last" id="imprint"><a href="imprint">Imprint</a></li>
  # </ul>
  #
  # As you can see: Everything you need.
  #
  # Not pleased with the way Alchemy produces the navigation structure?
  # Then feel free to overwrite the partials (_navigation_renderer.html.erb and _navigation_link.html.erb) found in views/pages/partials/ or pass different partials via the options :navigation_partial and :navigation_link_partial.
  #
  # == The options are:
  #
  # :submenu => false                                     Do you want a nested <ul> <li> structure for the deeper levels of your navigation, or not? Used to display the subnavigation within the mainnaviagtion. E.g. for dropdown menues.
  # :from_page => Page.language_root session[:language]      Do you want to render a navigation from a different page then the current_page? Then pass the Page object here.
  # :spacer => ""                                         Yeah even a spacer for the entries can be passed. Simple string, or even a complex html structure. E.g: "<span class='spacer'>|</spacer>". Only your imagination is the limit. And the W3C of course :)
  # :navigation_partial => "navigation_renderer"          Pass a different partial to be taken for the navigation rendering. CAUTION: Only for the advanced Alchemy webdevelopers. The standard partial takes care of nearly everything. But maybe you are an adventures one ^_^
  # :navigation_link_partial => "navigation_link"         Alchemy places an <a> html link in <li> tags. The tag automatically has an active css class if necessary. So styling is everything. But maybe you don't want this. So feel free to make you own partial and pass the filename here.
  # :show_nonactive => false                              Commonly Alchemy only displays the submenu of the active page (if :submenu => true). If you want to display all child pages then pass true (together with :submenu => true of course). E.g. for the popular css-driven dropdownmenues these days.
  # :show_title => true                                  For our beloved SEOs :). Appends a title attribute to all links and places the page.title content into it.
  def render_navigation(options = {})
    default_options = {
      :submenu => false,
      :all_sub_menues => false,
      :from_page => root_page,
      :spacer => "",
      :navigation_partial => "partials/navigation_renderer",
      :navigation_link_partial => "partials/navigation_link",
      :show_nonactive => false,
      :restricted_only => nil,
      :show_title => true,
      :level => 1
    }
    options = default_options.merge(options)
    if options[:from_page].nil?
      logger.warn %(\n
        ++++ WARNING: options[:from_page] is nil in render_navigation()\n
      )
      return ""
    else
      conditions = {
        :parent_id => options[:from_page].id,
        :restricted => options[:restricted_only] || false,
        :visible => true
      }
      if options[:restricted_only].nil?
        conditions.delete(:restricted)
      end
      pages = Page.all(
        :conditions => conditions,
        :order => "lft ASC"
      )
      render :partial => options[:navigation_partial], :locals => {:options => options, :pages => pages}
    end
  end

  # = This helper renders the paginated navigation.
  #
  # :pagination => {
  #   :level_X => {
  #     :size => X,
  #     :current => params[:navigation_level_X_page]
  #   }
  # }                                                     This one is a funky complex pagination option for the navigation. I'll explain in the next episode.
  def render_paginated_navigation(options = {})
    default_options = {
      :submenu => false,
      :all_sub_menues => false,
      :from_page => root_page,
      :spacer => "",
      :pagination => {},
      :navigation_partial => "pages/partials/navigation_renderer",
      :navigation_link_partial => "pages/partials/navigation_link",
      :show_nonactive => false,
      :show_title => true,
      :level => 1
    }
    options = default_options.merge(options)
    if options[:from_page].nil?
      logger.warn %(\n
        ++++ WARNING: options[:from_page] is nil in render_navigation()\n
      )
      return ""
    else
      pagination_options = options[:pagination].stringify_keys["level_#{options[:from_page].depth}"]
      find_conditions = { :parent_id => options[:from_page].id, :visible => true }
      pages = Page.all(
        :page => pagination_options,
        :conditions => find_conditions,
        :order => "lft ASC"
      )
      render :partial => options[:navigation_partial], :locals => {:options => options, :pages => pages}
    end
  end
  
  # Renders the same html structure like the render_navigation() helper, but renders only child pages from current_page.
  # Shows the child pages of the active child page as default.
  # Take this helper if you want to render the subnavigation independent from the mainnavigation. E.g. to place it in a different <div> on your page.
  def render_subnavigation options = {}
    default_options = {
      :submenu => true,
      :from_page => current_page,
      :spacer => "",
      :navigation_partial => "partials/navigation_renderer",
      :navigation_link_partial => "partials/navigation_link",
      :show_nonactive => false
    }
    options = default_options.merge(options)
    if options[:from_page].nil?
      logger.warn("WARNING: No page for subnavigation found!")
      return ""
    else
      if options[:from_page].level == 2
        pages = options[:from_page].children
      elsif options[:from_page].level == 3
        pages = options[:from_page].parent.children
      elsif options[:from_page].level == 4
        pages = options[:from_page].parent.self_and_siblings
      else
        pages = options[:from_page].self_and_siblings
      end
      pages = pages.select{ |page| page.public? && page.visible?}
      pages = pages.sort{|x, y| x.self_and_siblings.index(x) <=> y.self_and_siblings.index(y) }
      render :partial => options[:navigation_partial], :locals => {:options => options, :pages => pages}
    end
  end
  
  # Used to display the pagination links for the paginated navigation.
  def link_to_navigation_pagination name, urlname, pages, page, css_class = ""
    p = {}
    p["navigation_level_1_page"] = params[:navigation_level_1_page] unless params[:navigation_level_1_page].nil?
    p["navigation_level_2_page"] = params[:navigation_level_2_page] unless params[:navigation_level_2_page].nil?
    p["navigation_level_3_page"] = params[:navigation_level_3_page] unless params[:navigation_level_3_page].nil?
    p["navigation_level_#{pages.to_a.first.depth}_page"] = page
    link_to name, show_page_url(urlname, p), :class => (css_class unless css_class.empty?)
  end  
  
  # Returns true if the current_user (The logged-in Alchemy User) has the admin role.
  def is_admin?
    return false if !current_user
    current_user.admin?
  end
  
  # This helper renders the link for a protoypejs-window overlay. We use this for our fancy modal overlay windows in the Alchemy cockpit.
  def link_to_overlay_window(content, url, options={}, html_options={})
    default_options = {
      :size => "100x100",
      :resizable => false,
      :modal => true
    }
    options = default_options.merge(options)
    link_to_function(
      content,
      "openOverlayWindow(
        \'#{url}\',
        \'#{options[:title]}\',
        \'#{options[:size].split('x')[0].to_s}\',
        \'#{options[:size].split('x')[1].to_s}\',
        \'#{options[:resizable]}\',
        \'#{options[:modal]}\',
        \'#{options[:overflow]}\'
      )",
      html_options
    )
  end
  
  # Used for rendering the folder link in Admin::Pages.index sitemap.
  def sitemapFolderLink(page, title)
    return '' if page.level == 1
    css_class = page.folded?(current_user.id) ? 'folded' : 'collapsed'
    link_to_remote(
      '',
      :url => {
        :controller => 'admin/pages',
        :action => :fold,
        :id => page.id
      },
      :complete => %(
        foldPage(#{page.id})
      ),
      :html => {
        :class => "page_folder #{css_class}",
        :title => title,
        :id => "fold_button_#{page.id}"
      }
    )
  end
  
  # Renders an image_tag with .png for file.suffix.
  # The images are in vendor/plugins/alchemy/assets/images/file_icons
  # Fileicons so far:
  # GIF
  # PDF
  # FLV (Flashvideo)
  # ZIP
  # SWF (Flashmovie)
  # MP3
  # Empty File
  def render_file_icon file
    if file.filename.split(".").last == "pdf"
      img_tag = "#{image_tag("file_icons/pdf.png", :plugin => :alchemy)}"
    elsif file.filename.split(".").last == "flv"
      img_tag = "#{image_tag("file_icons/flv.png", :plugin => :alchemy)}"
    elsif file.filename.split(".").last == "gif"
      img_tag = "#{image_tag("file_icons/gif.png", :plugin => :alchemy)}"
    elsif file.filename.split(".").last == "zip"
      img_tag = "#{image_tag("file_icons/zip.png", :plugin => :alchemy)}"
    elsif file.filename.split(".").last == "mp3"
      img_tag = "#{image_tag("file_icons/mp3.png", :plugin => :alchemy)}"
    elsif file.filename.split(".").last == "swf"
      img_tag = "#{image_tag("file_icons/swf.png", :plugin => :alchemy)}"
    elsif file.filename.split(".").last == "doc"
      img_tag = "#{image_tag("file_icons/doc.png", :plugin => :alchemy)}"
    elsif file.filename.split(".").last == "jpg"
      img_tag = "#{image_tag("file_icons/jpg.png", :plugin => :alchemy)}"
    else
      img_tag = "#{image_tag("file_icons/file.png", :plugin => :alchemy)}"
    end
  end
  
  # Renders an image_tag from for an image in public/images folder so it can be cached.
  # *Not really working!*
  def static_image_tag image, options={}
    image_tag url_for(:controller => :images, :action => :show_static, :image => image)
  end
  
  # Renders the layout from current_page.page_layout. File resists in /app/views/page_layouts/_LAYOUT-NAME.html.erb
  def render_page_layout(options={})
    default_options = {
      :render_format => "html"
    }
    options = default_options.merge(options)
    if File.exists?("#{RAILS_ROOT}/app/views/page_layouts/_#{@page.page_layout.downcase}.#{options[:render_format]}.erb") || File.exists?("#{RAILS_ROOT}/vendor/plugins/alchemy/app/views/page_layouts/_#{@page.page_layout.downcase}.#{options[:render_format]}.erb")
      render :partial => "page_layouts/#{@page.page_layout.downcase}.#{options[:render_format]}.erb"
    else
      render :partial => "page_layouts/standard"
    end
  end
  
  # returns @page set in the action (e.g. Page.by_name)
  def current_page
    if @page.nil?
      logger.warn %(\n
        ++++ WARNING: @page is not set. Rendering Rootpage instead.\n
      )
      return @page = root_page
    else
      @page
    end
  end

  # returns the current language root
  def root_page
    @root_page ||= Page.language_root(session[:language])
  end
  
  # Returns true if the current_page is the root_page in the nested set of Pages, false if not.
  def root_page?
    current_page == root_page
  end
  
  # Returns the full url containing host, page and anchor for the given element
  def full_url_for_element element
    "http://" + request.env["HTTP_HOST"] + "/" + element.page.urlname + "##{element.name}_#{element.id}"  
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
      :onkeyup => "alchemyListFilter('#contact_list li')",
      :id => "search_field"
    }
    options = default_options.merge(options)
    options[:onkeyup] << ";$('search_field').value.length >= 1 ? $$('.js_filter_field_clear')[0].show() : $$('.js_filter_field_clear')[0].hide();"
    filter_field = "<div class=\"js_filter_field_box\">"
    filter_field << text_field_tag("filter", "", options)
    filter_field << link_to_function(
      "",
      "$('#{options[:id]}').value = '';#{options[:onkeyup]}",
      :class => "js_filter_field_clear",
      :style => "display:none",
      :title => _("click_to_show_all")
    )
    filter_field << ("<br /><label for=\"search_field\">" + _("search") + "</label>")
    filter_field << "</div>"
    filter_field
  end

  # returns all elements that could be placed on that page because of the pages layout as array to be used in alchemy_selectbox form builder
  def elements_for_select(elements)
    return [] if elements.nil?
    options = elements.collect{|p| [p["display_name"], p["name"]]}
    unless session[:clipboard].nil?
      pastable_element = Element.get_from_clipboard(session[:clipboard])
      if !pastable_element.nil?
        options << [
          _("'%{name}' from_clipboard") % {:name => "#{pastable_element.display_name_with_preview_text}"},
          "paste_from_clipboard"
        ]
      end
    end
    options
  end

  def link_to_confirmation_window(link_string = "", message = "", url = "", html_options = {})
    ajax = remote_function(:url => url, :success => "confirm.close()", :method => :delete)
    link_to_function(
      link_string,
      "confirm = Dialog.confirm( '#{message}', {zIndex: 30000, width:300, height: 80, okLabel: '" + _("yes") + "', cancelLabel: '" + _("no") + "', buttonClass: 'button', id: 'alchemy_confirm_window', className: 'alchemy_window', closable: true, title: '" + _("please_confirm") + "', draggable: true, recenterAuto: false, effectOptions: {duration: 0.2}, cancel:function(){}, ok:function(){ " + ajax + " }} );",
      html_options
    )
  end

  def page_selector(element, content_name, options = {}, select_options = {})
    default_options = {
      :except => {
        :page_layout => [""]
      },
      :only => {
        :page_layout => [""]
      }
    }
    options = default_options.merge(options)
    content = element.content_by_name(content_name)
    if content.nil?
      logger.warn %(\n
        ++++ WARNING: Content is nil!\n
      )
      return "<p class=\"content_editor_error\">" + _("content_not_found") + "</p>"
    elsif content.essence.nil?
      logger.warn %(\n
        ++++ WARNING: Content.essence is nil!\n
      )
      return "<p class=\"content_editor_error\">" + _("content_essence_not_found") + "</p>"
    end
    pages = Page.find(
      :all,
      :conditions => {
        :language => session[:language],
        :page_layout => options[:only][:page_layout],
        :public => true
      }
    )
    select_tag(
      "contents[content_#{content.id}][body]",
      pages_for_select(pages, content.essence.body),
      select_options
    )
  end

  # Returns all Pages found in the database as an array for the rails select_tag helper.
  # You can pass a collection of pages to only returns these pages as array.
  # Pass an Page.name or Page.urlname as second parameter to pass as selected for the options_for_select helper.
  def pages_for_select(pages = nil, selected = nil, prompt = "Bitte wählen Sie eine Seite")
    result = [[prompt, ""]]
    if pages.blank?
      pages = Page.find_all_by_language_and_public(session[:language], true)
    end
    pages.each do |p|
      result << [p.send(:name), p.send(:urlname)]
    end
    options_for_select(result, selected)
  end

  # Returns all public elements found by Element.name.
  # Pass a count to return only an limited amount of elements.
  def all_elements_by_name(name, options = {})
    default_options = {
      :count => :all,
      :from_page => :all,
      :language => session[:language]
    }
    options = default_options.merge(options)
    if options[:from_page] == :all
      elements = Element.find_all_by_name_and_public(name, true, :limit => options[:count] == :all ? nil : options[:count])
    elsif options[:from_page].class == String
      page = Page.find_by_page_layout_and_language(options[:from_page], options[:language])
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

  # This helper renderes the picture editor for the elements on the Alchemy Desktop.
  # It brings full functionality for adding images to the element, deleting images from it and sorting them via drag'n'drop.
  # Just place this helper inside your element editor view, pass the element as parameter and that's it.
  #
  # Options:
  # :maximum_amount_of_images (integer), default nil. This option let you handle the amount of images your customer can add to this element.
  def render_picture_editor(element, options={})
    default_options = {
      :last_image_deletable => true,
      :maximum_amount_of_images => nil,
      :refresh_sortable => true
    }
    options = default_options.merge(options)
    picture_contents = element.all_contents_by_type("EssencePicture")
    render(
      :partial => "admin/elements/picture_editor",
      :locals => {
        :picture_contents => picture_contents,
        :element => element,
        :options => options
      }
    )
  end
  
  def render_essence_selection_editor(element, content, select_options)
    if content.class == String
       content = element.contents.find_by_name(content)
    else
      content = element.contents[content - 1]
    end
    if content.essence.nil?
      logger.warn %(\n
        ++++ WARNING: Element is nil!\n
        Usage: render_essence_editor_by_position(element, position, options = {})\n
      )
      return _("content_essence_not_found")
    end
    select_options = options_for_select(select_options, content.essence.content)
    select_tag(
      "contents[content_#{content.id}]",
      select_options
    )
  end
  
  def picture_editor_sortable(element_id)
    sortable_element(
      "element_#{element_id}_contents",
      :scroll => 'window',
      :tag => 'div',
      :only => 'dragable_picture',
      :handle => 'picture_handle',
      :constraint => '',
      :overlap => 'horizontal',
      :url => order_admin_contents_path(:element_id => element_id)
    )
  end
  
  def current_language
    session[:language]
  end
  
  # TOOD: include these via asset_packer yml file
  def stylesheets_from_plugins
    Dir.glob("vendor/plugins/*/assets/stylesheets/*.css").select{|s| !s.include? "vendor/plugins/alchemy"}.inject("") do |acc, s|
      filename = File.basename(s)
      plugin = s.split("/")[2]
      acc << stylesheet_link_tag(filename, :plugin => plugin)
    end
  end

  # TOOD: include these via asset_packer yml file  
  def javascripts_from_plugins
    Dir.glob("vendor/plugins/*/assets/javascripts/*.js").select{|s| !s.include? "vendor/plugins/alchemy"}.inject("") do |acc, s|
      filename = File.basename(s)
      plugin = s.split("/")[2]
      acc << javascript_include_tag(filename, :plugin => plugin)
    end
  end

  def admin_main_navigation
    navigation_entries = alchemy_plugins.collect{ |p| p["navigation"] }
    render :partial => 'layouts/partials/mainnavigation_entry', :collection => navigation_entries.flatten
  end

  #:nodoc:
  def render_admin_subnavigation(entries)
    render :partial => "layouts/partials/sub_navigation", :locals => {:entries => entries}
  end

  def admin_subnavigation
    plugin = alchemy_plugin(:controller => params[:controller], :action => params[:action])
    unless plugin.nil?
      entries = plugin["navigation"]['sub_navigation']
      render_admin_subnavigation(entries) unless entries.nil?
    else
      ""
    end
  end
  
  #true if the current controller/action pair wants to display content other than the default.
  def frame_requested?
    preview_frame = {}
    plugin = alchemy_plugins.detect do |p|
      unless p["preview_frame"].nil?
        if p['preview_frame'].is_a?(Array)
          preview_frame = p['preview_frame'].detect(){ |f| f["controller"] == params[:controller] && f["action"] == params[:action] }
        else
          if p["preview_frame"]["controller"] == params[:controller] && p["preview_frame"]["action"] == params[:action]
            preview_frame = p["preview_frame"]
          end
        end
      end
    end
    return false if plugin.blank?
    preview_frame
  end
  
  def admin_mainnavi_active?(mainnav)
    subnavi = mainnav["sub_navigation"]
    nested = mainnav["nested"]
    if !subnavi.blank?
      (!subnavi.detect{ |subnav| subnav["controller"] == params[:controller] && subnav["action"] == params[:action] }.blank?) ||
      (!nested.nil? && !nested.detect{ |n| n["controller"] == params[:controller] && n["action"] == params[:action] }.blank?)
    else
      mainnav["controller"] == params[:controller] && mainnav["action"] == params["action"]
    end
  end
  
  # Generates the url for the preview frame.
  # target_url must contain target_controller and target_action.
  def generate_preview_url(target_url)
    preview_url = url_for(
      :controller => ('/' + target_url["target_controller"]),
      :action => target_url["target_action"],
      :id => params[:id]
    )
  end
  
  # Returns a string for the id attribute of a html element for the given element
  def element_dom_id(element)
    return "" if element.nil?
    "#{element.name}_#{element.id}"
  end
  
  # Returns a string for the id attribute of a html element for the given content
  def content_dom_id(content)
    return "" if content.nil?
    if content.class == String
      a = Content.find_by_name(content)
      return "" if a.nil?
    else
      a = content
    end
    "#{a.essence_type.underscore}_#{a.id}"
  end
  
  # Helper for including the nescessary javascripts and stylesheets for the different views.
  # Together with the asset_packager plugin we achieve a lot better load time.
  def alchemy_assets_set(setname = 'default')
    content_for(:javascript_includes){ javascript_include_merged(setname.to_sym) }
    content_for(:stylesheets){ stylesheet_link_merged(setname.to_sym) }
  end
  
  def parse_sitemap_name(page)
    if multi_language?
      pathname = "/#{session[:language]}/#{page.urlname}"
    else
      pathname = "/#{page.urlname}"
    end
    pathname
  end
  
  def render_new_content_link(element)
    link_to_overlay_window(
      _('add new content'),
      new_element_content_path(element),
      {
        :size => '305x40',
        :title => _('Select an content'),
        :overflow => true
      },
      {
        :id => "add_content_for_element_#{element.id}",
        :class => 'button new_content_link'
      }
    )
  end
  
  def render_create_content_link(element, options = {})
    defaults = {
      :label => _('add new content')
    }
    options = defaults.merge(options)
    link_to_remote(
      options[:label],
      {
        :url => contents_path(
          :content => {
            :name => options[:content_name],
            :element_id => element.id
          }
        ),
        :method => 'post'
      },
      {
        :id => "add_content_for_element_#{element.id}",
        :class => 'button new_content_link'
      }
    )
  end
  
  # Returns a icon suitable for a link with css class 'icon_button'
  def render_icon(icon_class)
    content_tag('span', '', :class => "icon #{icon_class}")
  end
  
  def alchemy_preview_mode_code
    if @preview_mode
      str = javascript_include_merged(:preview)
      str += %(
        <script type="text/javascript" charset="utf-8">
        // <![CDATA[
          document.observe('dom:loaded', function() {
            new AlchemyElementSelector();
          });
        // ]]>
        </script>
      )
      return str
    else
      return nil
    end
  end
  
end
