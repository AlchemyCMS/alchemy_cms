module WaPagesHelper
  
  # DEPRICATED! Use WaMolecule.preview_text instead.
  def get_preview_text molecule
    molecule.preview_text
  end
  
  def render_classes classes=[]
    s = classes.uniq.delete_if{|x| x == nil || x.blank?}.join(" ")
    s.blank? ? "" : "class='#{s}'"
  end
  
  def picture_atom_caption wa_atom
    return "" if wa_atom.nil?
    return "" if wa_atom.atom.nil?
    wa_atom.atom.caption
  end
  
  def wa_form_select(name, select_options, options={})
    select "mail_data", name, select_options, :selected => (session[:mail_data][name.to_sym] rescue "")
  end
  
  def wa_form_input_field(name, options = {})
    if options[:value].blank? && session[:mail_data].blank?
      value = nil
    elsif options[:value].blank? && !session[:mail_data].blank?
      value = session[:mail_data][name.to_sym]
    else
      value = options[:value]
    end
    text_field("mail_data", name, {:value => value}.merge(options))
  end
  
  def wa_form_text_area(name, options={})
    text_area "mail_data", name, :class => options[:class], :value => (session[:mail_data][name.to_sym] rescue "")
  end
  
  def wa_form_check_box(name, options={})
    bla = check_box_tag "mail_data[#{name}]", 1, (session[:mail_data][name.to_sym] == "0" ? false : true rescue false)
    bla += hidden_field_tag "mail_data[#{name}]", 0, :id => nil
  end
  
  def wa_form_label(wa_molecule, name, options={})
    label_tag "mail_data_#{name}", render_atom_view_by_name(wa_molecule, name), options
  end
  
  def wa_form_reset_button(name, options={})
    button_to_function(
      name,
      remote_function(
        :url => {
          :controller => "wa_contact_form",
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
  
end
