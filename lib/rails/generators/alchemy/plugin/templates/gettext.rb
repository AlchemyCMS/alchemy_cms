require 'fast_gettext'
FastGettext.add_text_domain '<%= @plugin_name %>', :path => File.join(File.dirname(__FILE__), '..', '..', 'locale'), :format => :po
