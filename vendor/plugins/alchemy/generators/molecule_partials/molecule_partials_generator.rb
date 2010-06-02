class MoleculePartialsGenerator < Rails::Generator::Base
  require 'yaml'
  
  def initialize(runtime_args, runtime_options={})
    super
      @options[:collision] = :skip
      @molecules = get_molecules_from_yaml
  end
  
  def manifest
    record do |m|
      m.directory "app/views/molecules"
      @molecules.each do |molecule|
        m.template(
          "editor.html.erb",
          "app/views/molecules/_#{molecule["name"]}_editor.html.erb",
          :assigns => { :atoms => molecule["atoms"] }
        )
        m.template(
          "view.html.erb",
          "app/views/molecules/_#{molecule["name"]}_view.html.erb",
          :assigns => { :atoms => molecule["atoms"], :molecule_name => molecule["name"] }
        )
      end
    end
  end

  private
    
    def get_molecules_from_yaml
      if File.exists? "#{RAILS_ROOT}/config/alchemy/molecules.yml"
        @molecules = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/molecules.yml" )
      elsif File.exists? "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/molecules.yml"
        @molecules = YAML.load_file( "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/molecules.yml" )
      else
        raise "Could not read config/alchemy/molecules.yml"
      end
    end

end
