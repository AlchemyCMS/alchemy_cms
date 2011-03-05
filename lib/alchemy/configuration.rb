class Alchemy::Configuration < ActionController::Base
  
  def self.parameter(name)
    show[name.to_s]
  end
  
  def self.get(name)
    parameter(name)
  end
  
  def self.show
    read_files
  end

private

  def self.read_files
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
    config_1.stringify_keys!
    config_2.stringify_keys!
    config_3.stringify_keys!
    config_3.merge(config_2.merge(config_1))
  end
  
end
