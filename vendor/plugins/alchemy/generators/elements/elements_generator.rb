class ElementsGenerator < Rails::Generator::Base
  require 'yaml'
  
  def initialize(runtime_args, runtime_options={})
    super
      @options[:collision] = :skip
      @elements = get_elements_from_yaml
  end
  
  def manifest
    record do |m|
      m.directory "app/views/elements"
      @elements.each do |element|
        m.template(
          "editor.html.erb",
          "app/views/elements/_#{element["name"]}_editor.html.erb",
          :assigns => { :contents => element["contents"] }
        )
        m.template(
          "view.html.erb",
          "app/views/elements/_#{element["name"]}_view.html.erb",
          :assigns => { :contents => element["contents"], :element_name => element["name"] }
        )
      end
    end
  end

private
  
  def get_elements_from_yaml
    if File.exists? "#{RAILS_ROOT}/config/alchemy/elements.yml"
      @elements = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/elements.yml" )
    elsif File.exists? "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/elements.yml"
      @elements = YAML.load_file( "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/elements.yml" )
    else
      raise "Could not read config/alchemy/elements.yml"
    end
  end

end
