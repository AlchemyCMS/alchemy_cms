module WaContactFormHelper

  def contact_text_field name
    text_field "mail_data", name, :class => "field", :id => "text_field_#{name}", :value => (session[:mail_data][name] rescue "")
  end

  def contact_select name, choices = []
    select "mail_data", name, choices, :class => "select", :id => "select_field_#{name}", :selected => (session[:mail_data][name] rescue "")
  end

end