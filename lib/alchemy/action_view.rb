module Alchemy::ActionView
  
  # values = [[], []]
  def alchemy_selectbox_tag(name, values, selected_value, options = {})
    id = name.gsub(/(\[|\])/, '_') + '_select'
    selected_value = values.detect(){ |v| v[1] == selected_value }
    nothing_selected = selected_value.blank?
    first_value = (values[0][0] rescue '&nbsp;')
    if nothing_selected
      if !options[:prompt].blank?
        select_box_content = options[:prompt]
      elsif !options[:include_blank?].blank?
        select_box_content = "&nbsp;"
      else
        select_box_content = first_value
      end
    else
      select_box_content = selected_value[0]
    end
    html = Alchemy::ActionView.get_html_scaffold(:prefix, id, select_box_content, '', options)
    unless options[:prompt].blank? || nothing_selected
      html += %(<a href="#" rel="">#{options[:prompt]}</a>)
    end
    values.each do |value|
      selected = (selected_value[1] == value[1] rescue false)
      html += %(
        <a href="#" rel="#{value[1]}" title="#{value[0]}" class="#{selected ? 'selected' : nil}">#{value[0]}</a>
      )
    end
    html += Alchemy::ActionView.get_html_scaffold(:suffix, '', '', '', options)
    if !options[:prompt].blank? && nothing_selected
      html += self.hidden_field_tag(name)
    else
      html += self.hidden_field_tag(name, (values[0][1] rescue '&nbsp;'))
    end
    html += Alchemy::ActionView.get_html_scaffold(:js, id, '', name, options)
    return html
  end

  def self.get_html_scaffold(part, id, content, hidden_field_id, options = {})
    html_scaffold = {
      :prefix => %(
        <div class="alchemy_selectbox" id="#{id}" class="#{options[:class]}" style="#{options[:style]}">
    	    <div class="alchemy_selectbox_link_bg">
    		    <a href="#" class="alchemy_selectbox_link">
    		      <span class="alchemy_selectbox_link_content">#{content}</span>
      		    <span class="alchemy_selectbox_link_arrow"></span>
    		    </a>
    	    </div>
    	    <div class="alchemy_selectbox_body" style="display: none;">
      ),
      :suffix => %(
      	  </div>
        </div>
      ),
      :js => %(
        <script type="text/javascript" charset="utf-8">
        //<!--[CDATA[
      	  alchemy_selectbox_#{id} = new AlchemySelectbox('#{id}', {
      	    update: '#{hidden_field_id}',
      	    afterSelect: function(value) {
      	      #{options[:onchange]}
      	    }
      	  });
        //]]-->
        </script>
      )
    }
    html_scaffold[part.to_sym]
  end
  
end
ActionView::Base.send(:include, Alchemy::ActionView)
