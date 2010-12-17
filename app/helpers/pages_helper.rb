module PagesHelper
  
  # DEPRICATED! Use Element.preview_text instead.
  def get_preview_text element
    element.preview_text
  end
  
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
    bla = check_box_tag "mail_data[#{name}]", 1, (session[:mail_data][name.to_sym] == "0" ? false : true rescue false)
    bla += hidden_field_tag "mail_data[#{name}]", 0, :id => nil
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
  
  def language_switches(options={})
    default_options = {
      :linkname => "code",
      :spacer => "",
      :uppercase => true,
      :link_to_public_child => false,
      :show_title => true,
      :reverse => false
    }
    options = default_options.merge(options)
    if multi_language?
      links = []
      
      Page.public_language_roots.each do |page|
        page = (options[:link_to_public_child] ? (page.first_public_child.blank? ? page : page.first_public_child) : page)
        if page.language.has_attribute?("#{options[:linkname]}")
          linkname = page.language.send("#{options[:linkname]}")
          linkname.upcase! if options[:uppercase]
        else
          linkname = page.language.code
        end
        links << link_to(
          linkname,
          show_page_with_language_path(:urlname => page.urlname, :lang => page.language.code),
          :class => (session[:language_id] == page.language.id ? 'active' : nil),
          :title => (options[:show_title] == true ? (linkname) : nil)
        )
      end
      links.reverse! if options[:reverse]
      links.join("<span class='seperator'>#{options[:spacer]}</span>")
    else
      ""
    end
  end
  
end
