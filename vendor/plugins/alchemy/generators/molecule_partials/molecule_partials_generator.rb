class MoleculePartialsGenerator < Rails::Generator::Base
  require 'yaml'
  
  def initialize(runtime_args, runtime_options={})
    super
      @options[:collision] = :skip
      @molecules = get_molecules_from_yaml
  end
  
  def manifest
    record do |m|
      m.directory "app/views/wa_molecules"
      @molecules.each do |molecule|
        m.template(
          "editor.html.erb",
          "app/views/wa_molecules/_#{molecule["name"]}_editor.html.erb",
          :assigns => { :atoms => molecule["wa_atoms"] }
        )
        m.template(
          "view.html.erb",
          "app/views/wa_molecules/_#{molecule["name"]}_view.html.erb",
          :assigns => { :atoms => molecule["wa_atoms"], :molecule_name => molecule["name"] }
        )
      end
    end
  end

  private
    
    def get_molecules_from_yaml
      if File.exists? "#{RAILS_ROOT}/config/washapp/molecules.yml"
        @molecules = YAML.load_file( "#{RAILS_ROOT}/config/washapp/molecules.yml" )
      elsif File.exists? "#{RAILS_ROOT}/vendor/plugins/washapp/config/washapp/molecules.yml"
        @molecules = YAML.load_file( "#{RAILS_ROOT}/vendor/plugins/washapp/config/washapp/molecules.yml" )
      else
        raise "Could not read config/washapp/molecules.yml"
      end
    end

end
