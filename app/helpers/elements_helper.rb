module ElementsHelper
  
  include EssencesHelper
  
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
      element_string.html_safe
    end
  end

  # This helper renders the Element partial for either the view or the editor part.
  # Generate element partials with ./script/generate elements
  def render_element(element, part = :view, options = {}, i = 1)
    begin
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
        path1 = "#{Rails.root}/app/views/elements/"
        path2 = "#{Rails.root}/vendor/plugins/alchemy/app/views/elements/"
        partial_name = "_#{element.name.underscore}_#{part}.html.erb"
        locals = options.delete(:locals)
        render(
          :partial => "elements/#{element.name.underscore}_#{part}.#{options[:render_format]}.erb",
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
      render :partial => "elements/#{part}_not_found", :locals => {:name => element.name, :error => "Element #{part} partial not found. Use rails generate alchemy:elements to generate them."}
    end
  end

  # Renders the element editor partial
  def render_editor(element)
    render_element(element, :editor)
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

end
