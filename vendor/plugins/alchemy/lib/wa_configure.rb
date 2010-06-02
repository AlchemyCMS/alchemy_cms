class WaConfigure < ActionController::Base
  
  def self.parameter(name)
    if name.class == String
      name = name.to_sym
    end
    if File.exists? "#{RAILS_ROOT}/config/alchemy/config_#{RAILS_ENV}.yml"
      config_1 = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/config_#{RAILS_ENV}.yml" )
    else
      config_1 = {}
    end
    if File.exists? "#{RAILS_ROOT}/config/alchemy/config.yml"
      config_2 = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/config.yml" )
    else
      config_2 = {}
    end
    if File.exists? "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/config.yml"
      config_3 = YAML.load_file( "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/config.yml" )
    else
      config_3 = {}
    end
    @config = config_3.merge(config_2.merge(config_1))
    return @config[name]
  end
  
  def self.sortable_molecules(page)
    page.sortable(
      "wa_molecule_area",
      :url => {
        :controller => 'wa_molecules',
        :action => "order"
      },
      :scroll => "window",
      :tag => 'div',
      :only => 'dragable',
      :dropOnEmpty => false,
      :handle => 'molecule_handle'
    )
  end
  
  def self.sortable_atoms(page, wa_molecule)
    page.sortable(
      "molecule_#{wa_molecule.id}_atoms",
      :scroll => 'window',
      :tag => 'div',
      :only => 'dragable_picture',
      :handle => 'picture_handle',
      :constraint => '',
      :overlap => 'horizontal',
      :url => {
        :controller => 'wa_atoms',
        :action => "order",
        :wa_molecule_id => wa_molecule.id
      }
    )
  end
  
end
