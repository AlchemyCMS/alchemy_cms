module PagesHelper

  def render_classes classes=[]
    s = classes.uniq.delete_if{|x| x == nil || x.blank?}.join(" ")
    s.blank? ? "" : "class='#{s}'"
  end

  def picture_essence_caption(content)
    return "" if content.nil?
    return "" if content.essence.nil?
    content.essence.caption
  end

  def alchemy_form_select(name, select_options, options={})
    select "mail_data", name, select_options, :selected => (session[:mail_data][name.to_sym] rescue "")
  end

  def alchemy_form_input_field(name, options = {})
    if options[:value].blank? && session[:mail_data].blank?
      value = nil
    elsif options[:value].blank? && !session[:mail_data].blank?
      value = session[:mail_data][name.to_sym]
    else
      value = options[:value]
    end
    text_field("mail_data", name, {:value => value}.merge(options))
  end

  def alchemy_form_text_area(name, options={})
    text_area "mail_data", name, :class => options[:class], :value => (session[:mail_data][name.to_sym] rescue "")
  end

  def alchemy_form_check_box(name, options={})
    box = hidden_field_tag "mail_data[#{name}]", 0, :id => nil
    box += check_box_tag("mail_data[#{name}]", 1, (session[:mail_data] && session[:mail_data][name.to_sym] == "1"))
    box
  end

  def alchemy_form_label(element, name, options={})
    label_tag "mail_data_#{name}", render_essence_view_by_name(element, name), options
  end

  def alchemy_form_reset_button(name, options={})
    button_to_function(
      name,
      remote_function(
        :url => {
          :controller => "contact_form",
          :action => "clear_session"
        },
        :before => %(
          this.form.reset();
          this.form.descendants().each(
            function(d){
              if ((d.type!='button') && (d.type!='submit') && (d.type!='hidden') && !d.disabled) {
                d.value = '';
                if (d.type == 'checkbox') {
                  d.checked = false;
                }
              }
            }
          )
        )
      ),
      options
    )
  end

  # helper for language switching
	# returns a string with links or nil
  def language_switches(options={})
    default_options = {
      :linkname => :name,
      :spacer => "",
      :link_to_public_child => configuration(:redirect_to_public_child),
      :link_to_page_with_layout => nil,
      :show_title => true,
      :reverse => false,
      :as_select_box => false
    }
    options = default_options.merge(options)
    if multi_language?
      language_links = []
      pages = (options[:link_to_public_child] == true) ? Page.language_roots : Page.public_language_roots
			return nil if pages.blank?
      pages.each_with_index do |page, i|
        if(options[:link_to_page_with_layout] != nil)
          page_found_by_layout = Page.where(:page_layout => options[:link_to_page_with_layout].to_s, :language_id => page.language_id)
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
              "#{content_tag(:span, '', :class => "flag")}#{ content_tag(:span, linkname)}".html_safe,
              show_page_path(:urlname => page.urlname, :lang => page.language.code),
              :class => "#{(active ? 'active ' : nil)}#{page.language.code} #{(i == 0) ? 'first' : (i==pages.length-1) ? 'last' : nil}",
              :title => options[:show_title] ? I18n.t("alchemy.language_links.#{page.language.code}.title", :default => page.language.name) : nil
            )
          end
        end
				# when last iteration and we have just one language_link, 
				# we dont need to render it.
				if (i==pages.length-1) && language_links.length == 1
					return nil
				end
      end
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
    end
  end

  def sitename_from_header_page
    header_page = Page.find_by_page_layout_and_layoutpage('layout_header', true)
    return "" if header_page.nil?
    page_title = header_page.elements.find_by_name('sitename')
    return "" if page_title.nil?
    page_title.ingredient('name')
  end

end
