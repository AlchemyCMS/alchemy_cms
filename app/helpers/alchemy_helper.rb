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
# 2. The currently displayed page can be accessed via the @page variable.
# 3. All important meta data from @page will be rendered via the render_meta_data() helper.

module AlchemyHelper
  
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

  # Renders all elements from @page.
  # ---
  # == Options are:
  # :only => []                 A list of element names to be rendered only. Very usefull if you want to render a specific element type in a special html part (e.g.. <div>) of your page and all other elements in another part.
  # :except => []               A list of element names to be rendered. The opposite of the only option.
  # :from_page                  The Page.page_layout string from which the elements are rendered from, or you even pass a Page object.
  # :count                      The amount of elements to be rendered (beginns with first element found)
  # :fallback => {:for => 'ELEMENT_NAME', :with => 'ELEMENT_NAME', :from => 'PAGE_LAYOUT'} when no element from this name is found on page, then use this element from that page
  # :sort_by => Content#name    A Content name to sort the elements by
  # :reverse => boolean         Reverse the rendering order
  #
  # This helper also stores all pages where elements gets rendered on, so we can sweep them later if caching expires!
  #
  def render_elements(options = {})
    default_options = {
      :except => [],
      :only => [],
      :from_page => "",
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
        page = Page.find_all_by_page_layout_and_language_id(options[:from_page], session[:language_id])
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
          if from = Page.find_by_page_layout(options[:fallback][:from])
            all_elements += from.elements.find_all_by_name(options[:fallback][:with].blank? ? options[:fallback][:for] : options[:fallback][:with])
          end
        end
      end
      all_elements.each_with_index do |element, i|
        element_string += render_element(element, :view, options, i+1)
      end
      element_string
    end
  end

  # This helper renders the Element partial for either the view or the editor part.
  # Generate element partials with ./script/generate elements
  def render_element(element, part = :view, options = {}, i = 1)
    if element.blank?
      warning('Element is nil')
      render :partial => "elements/#{part}_not_found", :locals => {:name => 'nil'}
    else
      default_options = {
        :shorten_to => nil,
        :render_format => "html"
      }
      options = default_options.merge(options)
      element.store_page(@page) if part == :view
      path1 = "#{RAILS_ROOT}/app/views/elements/"
      path2 = "#{RAILS_ROOT}/vendor/plugins/alchemy/app/views/elements/"
      partial_name = "_#{element.name.underscore}_#{part}.html.erb"
      if File.exists?(path1 + partial_name) || File.exists?(path2 + partial_name)
        locals = options.delete(:locals)
        render(
          :partial => "elements/#{element.name.underscore}_#{part}.#{options[:render_format]}.erb",
          :locals => {
            :element => element, 
            :options => options, 
            :counter => i
          }.merge(locals || {})
        )
      else
        warning(%(
          Element #{part} partial not found for #{element.name}.\n
          Looking for #{partial_name}, but not found
          neither in #{path1}
          nor in #{path2}
          Use ./script/generate elements to generate them.
          Maybe you still have old style partial names? (like .rhtml). Then please rename them in .html.erb'
        ))
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
      return part == :view ? "" : warning('Content is nil', _("content_not_found"))
    elsif content.essence.nil?
      return part == :view ? "" : warning('Essence is nil', _("content_essence_not_found"))
    end
    defaults = {
      :for_editor => {
        :as => 'text_field',
        :css_class => 'long',
        :render_format => "html"
      },
      :for_view => {
        :image_size => "120x90",
        :css_class => "",
        :date_format => "%d. %m. %Y, %H:%Mh",
        :caption => true,
        :blank_value => "",
        :render_format => "html"
      }
    }
    options_for_partial = defaults[('for_' + part.to_s).to_sym].merge(options[('for_' + part.to_s).to_sym])
    options = options.merge(defaults)
    render(
      :partial => "essences/#{content.essence.class.name.underscore}_#{part.to_s}.#{options_for_partial[:render_format]}.erb",
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
      return warning('Element is nil', _("no_element_given"))
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
      warning('Element is nil')
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
      warning('Element is nil')
      return ""
    end
    content = element.contents.find_by_position(position)
    render_essence(content, :view, :for_view => options)
  end

  # Renders the Content editor partial from the given Element by position (e.g. 1).
  # For options see -> render_essence
  def render_essence_editor_by_position(element, position, options = {})
    if element.blank?
      warning('Element is nil')
      return ""
    end
    content = element.contents.find_by_position(position)
    render_essence(content, :editor, :for_editor => options)
  end

  # Renders the Content editor partial found in views/contents/ for the content with name inside the passed Element.
  # For options see -> render_essence
  def render_essence_editor_by_name(element, name, options = {})
    if element.blank?
      return warning('Element is nil', _("no_element_given"))
    end
    content = element.content_by_name(name)
    render_essence(content, :editor, :for_editor => options)
  end

  # Renders the Content view partial from the passed Element for passed content name.
  # For options see -> render_essence
  def render_essence_view_by_name(element, name, options = {})
    if element.blank?
      warning('Element is nil')
      return ""
    end
    content = element.content_by_name(name)
    render_essence(content, :view, :for_view => options)
  end
  
  # Renders the name of elements content or the default name defined in elements.yml
  def render_content_name(content)
    if content.blank?
      warning('Element is nil')
      return ""
    else
      content_name = t("alchemy.content_names.#{content.element.name}.#{content.name}", :default => ["alchemy.content_names.#{content.name}".to_sym, content.name.capitalize])
    end
    if content.description.blank?
      warning("Content #{content.name} is missing its description")
      title = _("Warning: Content '%{contentname}' is missing its description.") % {:contentname => content.name}
  	  content_name = %(<span class="warning icon" title="#{title}"></span>&nbsp;) + content_name
  	end
  	content_name
  end

  # Returns @page.title
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
    unless @page.title.blank?
      h("#{default_options[:prefix]} #{default_options[:seperator]} #{@page.title}")
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
    lang = (@page.language.blank? ? options[:default_language] : @page.language.code)
    %(<meta name="#{options[:name]}" content="#{options[:content]}" lang="#{lang}" xml:lang="#{lang}" />)
  end

  # Renders a html <meta http-equiv="Content-Language" content="#{lang}" /> for @page.language.
  #
  # == Webdevelopers:
  # Please use the render_meta_data() helper. There all important meta information gets rendered in one helper.
  # So you dont have to worry about anything.
  def render_meta_content_language_tag(options={})
    default_options = {
      :default_language => "de"
    }
    options = default_options.merge(options)
    lang = (@page.language.blank? ? options[:default_language] : @page.language.code)
    %(<meta http-equiv="Content-Language" content="#{lang}" />)
  end

  # = This helper takes care of all important meta tags for your @page.
  # ---
  # The meta data is been taken from the @page.title, @page.meta_description, @page.meta_keywords, @page.updated_at and @page.language database entries managed by the Alchemy user via the Alchemy cockpit.
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
  # <title>Company :: #{@page.title}</title>
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
    if @page.meta_description.blank?
      description = Page.find_by_language_root_and_language_id(true, session[:language_id]).meta_description rescue ""
    else
      description = @page.meta_description
    end
    #render meta keywords of the root page from language if the current meta keywords is empty
    if @page.meta_keywords.blank?
      keywords = Page.find_by_language_root_and_language_id(true, session[:language_id]).meta_keywords rescue ""
    else
      keywords = @page.meta_keywords
    end
    robot = "#{@page.robot_index? ? "" : "no"}index, #{@page.robot_follow? ? "" : "no"}follow"
    meta_string = %(
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      #{render_meta_content_language_tag}
      #{render_title_tag( :prefix => options[:title_prefix], :seperator => options[:title_seperator])}
      #{render_meta_tag( :name => "description", :content => description)}
      #{render_meta_tag( :name => "keywords", :content => keywords)}
      <meta name="generator" content="Alchemy #{configuration(:alchemy_version)}" />
      <meta name="date" content="#{@page.updated_at}" />
      <meta name="robots" content="#{robot}" />
    )
    if @page.contains_feed?
    meta_string += %(
      <link rel="alternate" type="application/rss+xml" title="RSS" href="#{multi_language? ? show_page_with_language_url(:protocol => 'feed', :urlname => @page.urlname, :lang => @page.language_code, :format => :rss) : show_page_url(:protocol => 'feed', :urlname => @page.urlname, :format => :rss)}" />
    )
    end
    return meta_string
  end

  # Returns an array of all pages in the same branch from current. Used internally to find the active page in navigations.
  def breadcrumb(current)
    return [] if current.nil?
    result = Array.new
    result << current
    while current = current.parent
      result << current
    end
    return result.reverse
  end

  # Returns a html string for a linked breadcrumb from root to current page.
  # == Options:
  # :seperator => %(<span class="seperator">></span>)      Maybe you don't want this seperator. Pass another one.
  # :page => @page                                         Pass a different Page instead of the default (@page).
  # :without => nil                                        Pass Pageobject or array of Pages that must not be displayed.
  # :public_only => false                                  Pass boolean for displaying hidden pages only.
  # :visible_only => true                                  Pass boolean for displaying (in navigation) visible pages only.
  # :restricted_only => false                              Pass boolean for displaying restricted pages only.
  # :reverse => false                                      Pass boolean for displaying reversed breadcrumb.
  def render_breadcrumb(options={})
    default_options = {
      :seperator => %(<span class="seperator">&gt;</span>),
      :page => @page,
      :without => nil,
      :public_only => false,
      :visible_only => true,
      :restricted_only => false,
      :reverse => false
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
    if(options[:visible_only])
      pages.reject!{|p| !p.visible? }
    end
    if(options[:public_only])
      pages.reject!{|p| !p.public? }
    end
    if(options[:restricted_only])
      pages.reject!{|p| !p.restricted? }
    end
    if(options[:reverse])
      pages.reverse!
    end
    bc = []
    pages.each do |page|
      urlname = page.urlname
      (page.name == @page.name) ? css_class = "active" : nil
      if page == pages.last
        css_class.blank? ? css_class = "last" : css_class = [css_class, "last"].join(" ")
      elsif page == pages.first
        css_class.blank? ? css_class = "first" : css_class = [css_class, "last"].join(" ")
      end
      if multi_language? 
        url = show_page_with_language_url(:urlname => urlname, :lang => page.language_code)
      else
        url = show_page_url(:urlname => urlname)
      end
      bc << link_to( h(page.name), url, :class => css_class, :title => page.title )
    end
    bc.join(options[:seperator])
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
  # :from_page => @root_page                               Do you want to render a navigation from a different page then the current page? Then pass an Page instance or a PageLayout name as string.
  # :spacer => ""                                         Yeah even a spacer for the entries can be passed. Simple string, or even a complex html structure. E.g: "<span class='spacer'>|</spacer>". Only your imagination is the limit. And the W3C of course :)
  # :navigation_partial => "navigation_renderer"          Pass a different partial to be taken for the navigation rendering. CAUTION: Only for the advanced Alchemy webdevelopers. The standard partial takes care of nearly everything. But maybe you are an adventures one ^_^
  # :navigation_link_partial => "navigation_link"         Alchemy places an <a> html link in <li> tags. The tag automatically has an active css class if necessary. So styling is everything. But maybe you don't want this. So feel free to make you own partial and pass the filename here.
  # :show_nonactive => false                              Commonly Alchemy only displays the submenu of the active page (if :submenu => true). If you want to display all child pages then pass true (together with :submenu => true of course). E.g. for the popular css-driven dropdownmenues these days.
  # :show_title => true                                   For our beloved SEOs :). Appends a title attribute to all links and places the page.title content into it.
  def render_navigation(options = {})
    default_options = {
      :submenu => false,
      :all_sub_menues => false,
      :from_page => @root_page,
      :spacer => "",
      :navigation_partial => "partials/navigation_renderer",
      :navigation_link_partial => "partials/navigation_link",
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
    pages = Page.all(
      :conditions => conditions,
      :order => "lft ASC"
    )
    if options[:reverse]
      pages.reverse!
    end
    render :partial => options[:navigation_partial], :locals => {:options => options, :pages => pages}
  end
  
  # Renders the children of the given page (standard is the current page), the given page and its siblings if there are no children, or it renders just nil.
  # Use this helper if you want to render the subnavigation independent from the mainnavigation. E.g. to place it in a different layer on your website.
  # If :from_page's level in the site-hierarchy is greater than :level (standard is 2) and the given page has no children, the returned output will be the :from_page and it's siblings
  # This method will assign all its options to the the render_navigation method, so you are able to assign the same options as to the render_navigation method.
  # Normally there is no need to change the level parameter, just in a few special cases.
  def render_subnavigation(options = {})
    default_options = {
      :from_page => @page,
      :level => 2
    }
    options = default_options.merge(options)
    if !options[:from_page].nil?
      if (options[:from_page].children.blank? && options[:from_page].level > options[:level])
        options = options.merge(:from_page => Page.find(options[:from_page].parent_id))
      end
      render_navigation(options)
    else
      return nil
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
      :from_page => @root_page,
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
      warning('options[:from_page] is nil')
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
      "Alchemy.openWindow(
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
  def sitemapFolderLink(page)
    return '' if page.level == 1
    if page.folded?(current_user.id)
      css_class = 'folded'
      title = _('Show childpages')
    else
      css_class = 'collapsed'
      title = _('Hide childpages')
    end
    link_to_remote(
      '',
      :url => {
        :controller => 'admin/pages',
        :action => :fold,
        :id => page.id
      },
      :html => {
        :class => "page_folder #{css_class}",
        :title => title,
        :id => "fold_button_#{page.id}"
      }
    )
  end
  
  # Renders an image_tag from for an image in public/images folder so it can be cached.
  # *Not really working!*
  def static_image_tag image, options={}
    image_tag url_for(:controller => :images, :action => :show_static, :image => image)
  end
  
  # Renders the layout from @page.page_layout. File resists in /app/views/page_layouts/_LAYOUT-NAME.html.erb
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
  
  # Returns @current_language set in the action (e.g. Page.show)
  def current_language
    if @current_language.nil?
      warning('@current_language is not set')
      return nil
    else
      @current_language
    end
  end
  
  # Returns true if the current page is the root page in the nested set of Pages, false if not.
  def root_page?
    @page == @root_page
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
      :onkeyup => "Alchemy.ListFilter('#contact_list li')",
      :id => "search_field"
    }
    options = default_options.merge(options)
    options[:onkeyup] << ";jQuery('#search_field').val().length >= 1 ? jQuery('.js_filter_field_clear').show() : jQuery('.js_filter_field_clear').hide();"
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
  
  def clipboard_select_tag(items, html_options = {})
    unless items.blank?
      options = [[_('Please choose'), ""]]
      items.each do |item|
        options << [item.class.to_s == 'Element' ? item.display_name_with_preview_text : item.name, item.id]
      end
      select_tag(
  			'paste_from_clipboard',
  			options_for_select(options),
  			{
  			  :class => html_options[:class] || 'very_long',
  			  :style => html_options[:style]
  			}
  		)
    end
  end
  
  # returns all elements that could be placed on that page because of the pages layout as array to be used in alchemy_selectbox form builder
  def elements_for_select(elements)
    return [] if elements.nil?
    elements.collect { |p| [I18n.t("alchemy.element_names.#{p['name']}", :default => p['name'].capitalize), p['name']] }
  end
  
  def link_to_confirmation_window(link_string = "", message = "", url = "", html_options = {})
    title = _("please_confirm")
    ok_lable = _("yes")
    cancel_lable = _("no")
    link_to_function(
      link_string,
      "Alchemy.confirmToDeleteWindow('#{url}', '#{title}', '#{message}', '#{ok_lable}', '#{cancel_lable}');",
      html_options
    )
  end
  
  # Renders a form select tag for storing page ids
  # Options:
  #   * element - element the Content find via content_name to store the pages id in.
  #   * content_name - the name of the content from element to store the pages id in.
  #   * options (Hash)
  #   ** :only (Hash)  - pass page_layout names to :page_layout => [""] so only pages with this page_layout will be displayed inside the select.
  #   ** :except (Hash)  - pass page_layout names to :page_layout => [""] so all pages except these with this page_layout will be displayed inside the select.
  #   * select_options (Hash) - will be passed to the select_tag helper 
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
      return warning('Content', _('content_not_found'))
    elsif content.essence.nil?
      return warning('Content', _('content_essence_not_found'))
    end
    pages = Page.find(
      :all,
      :conditions => {
        :language_id => session[:language_id],
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
  # Pass an Page.name or Page.id as second parameter to pass as selected for the options_for_select helper.
  def pages_for_select(pages = nil, selected = nil, prompt = "")
    result = [[prompt.blank? ? _('Choose page') : prompt, ""]]
    if pages.blank?
      pages = Page.find_all_by_language_id_and_public(session[:language_id], true)
    end
    pages.each do |p|
      result << [p.name, p.id.to_s]
    end
    options_for_select(result, selected.to_s)
  end
  
  # Returns all public elements found by Element.name.
  # Pass a count to return only an limited amount of elements.
  def all_elements_by_name(name, options = {})
    warning('options[:language] option not allowed any more in all_elements_by_name helper')
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
      return warning('Element', _('content_essence_not_found'))
    end
    select_options = options_for_select(select_options, content.essence.content)
    select_tag(
      "contents[content_#{content.id}]",
      select_options
    )
  end
  
  # TOOD: include these via asset_packer yml file
  def stylesheets_from_plugins
    Dir.glob("vendor/plugins/*/assets/stylesheets/*.css").select{|s| !s.include? "vendor/plugins/alchemy"}.inject("") do |acc, s|
      filename = File.basename(s)
      plugin = s.split("/")[2]
      acc << stylesheet_link_tag("#{plugin}/#{filename}")
    end
  end

  # TOOD: include these via asset_packer yml file  
  def javascripts_from_plugins
    Dir.glob("vendor/plugins/*/assets/javascripts/*.js").select{|s| !s.include? "vendor/plugins/alchemy"}.inject("") do |acc, s|
      filename = File.basename(s)
      plugin = s.split("/")[2]
      acc << javascript_include_tag("#{plugin}/#{filename}")
    end
  end

  def admin_main_navigation
    navigation_entries = alchemy_plugins.collect{ |p| p["navigation"] }
    render :partial => 'layouts/partials/mainnavigation_entry', :collection => navigation_entries.flatten
  end

  # Renders the Subnavigation for the admin interface.
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
  # Together with the rails caching we achieve a good load time.
  def alchemy_assets_set(setname = 'combined')
    asset_sets = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'config/asset_packages.yml'))
    content_for(:javascript_includes) do 
      js_set = asset_sets['javascripts'].detect { |js| js[setname.to_s] }[setname.to_s]
      javascript_include_tag(js_set, :cache => 'alchemy/' + setname.to_s)
    end
    content_for(:stylesheets) do 
      css_set = asset_sets['stylesheets'].detect { |css| css[setname.to_s] }[setname.to_s]
      stylesheet_link_tag(css_set, :cache => 'alchemy/' + setname.to_s)
    end
  end
  
  def parse_sitemap_name(page)
    if multi_language?
      pathname = "/#{session[:language_code]}/#{page.urlname}"
    else
      pathname = "/#{page.urlname}"
    end
    pathname
  end
  
  def render_new_content_link(element)
    link_to_overlay_window(
      _('add new content'),
      new_admin_element_content_path(element),
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
  
  # Returns an icon
  def render_icon(icon_class)
    content_tag('span', '', :class => "icon #{icon_class}")
  end
  
  def alchemy_preview_mode_code
    if @preview_mode
      append_javascript = %(
var s = document.createElement('script');
s.src = '/javascripts/alchemy/jquery-1.5.min.js';
s.language = 'javascript';
s.type = 'text/javascript';
document.getElementsByTagName("body")[0].appendChild(s);
      )
      str = javascript_tag("if (typeof(jQuery) !== 'function') {#{append_javascript}}") + "\n"
      str += javascript_tag("jQuery.noConflict();") + "\n"
      str += javascript_include_tag("alchemy/alchemy") + "\n"
      str += javascript_tag("jQuery(document).ready(function() {\nAlchemy.ElementSelector();\n});\njQuery('a').attr('href', 'javascript:void(0)');")
      return str
    else
      return nil
    end
  end
  
  def element_preview_code(element)
    if @preview_mode
      "data-alchemy-element='#{element.id}'"
    end
  end
  
  # Logs a message in the Rails logger (warn level) and optionally displays an error message to the user.
  def warning(message, text = nil)
    logger.warn %(\n
      ++++ WARNING: #{message}! from: #{caller.first}\n
    )
    unless text.nil?
      warning = content_tag('p', :class => 'content_editor_error') do
        render_icon('warning') + text
      end
      return warning
    end
  end
  
  def alchemy_combined_assets
    alchemy_assets_set
  end
  
  # This helper returns a path for use inside a link_to helper.
  # You may pass a page_layout or an urlname.
  # Any additional options are passed to the url_helper, so you can add arguments to your url.
  # Example:
  #   <%= link_to '&raquo order now', page_path_for(:page_layout => 'orderform', :product_id => element.id) %>
  def page_path_for(options={})
    return warning("No page_layout, or urlname given. I got #{options.inspect} ") if options[:page_layout].blank? && options[:urlname].blank?
    if options[:urlname].blank?
      page = Page.find_by_page_layout(options[:page_layout])
      return warning("No page found for #{options.inspect} ") if page.blank?
      urlname = page.urlname
    else
      urlname = options[:urlname]
    end
    if multi_language?
      show_page_with_language_path({:urlname => urlname, :lang => @language.code}.merge(options.except(:page_layout, :urlname)))
    else
      show_page_path({:urlname => urlname}.merge(options.except(:page_layout, :urlname)))
    end
  end
  
  # Returns the current page.
  def current_page
    @page
  end
  
end
