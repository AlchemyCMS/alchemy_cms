if defined? FastGettext
  FastGettext.add_text_domain '<%= file_name %>', :path => File.join(File.dirname(__FILE__), 'locale'), :format => :po
  FastGettext.text_domain = '<%= file_name %>'
end
