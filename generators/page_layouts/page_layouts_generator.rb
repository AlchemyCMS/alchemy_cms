class PageLayoutsGenerator < Rails::Generator::Base
  require 'yaml'
  
  def initialize(runtime_args, runtime_options={})
    super
      @options[:collision] = :skip
      @page_layouts = get_layouts_from_yaml
  end
  
  def manifest
    record do |m|
      m.directory "app/views/page_layouts"
      @page_layouts.each do |layout|
        m.template(
          "layout.html.erb",
          "app/views/page_layouts/_#{layout["name"].downcase}.html.erb"
        )
      end
    end
  end

  private
    
    def get_layouts_from_yaml
      if File.exists? "#{RAILS_ROOT}/config/alchemy/page_layouts.yml"
        layout_file = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/page_layouts.yml" )
      elsif File.exists? "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/page_layouts.yml"
        layout_file = YAML.load_file( "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/page_layouts.yml" )
      else
        raise "Could not read config/alchemy/page_layouts.yml"
      end
      layout_file
    end

end
