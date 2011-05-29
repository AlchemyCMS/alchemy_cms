class AlchemyPluginGenerator < Rails::Generator::NamedBase
  
  attr_reader :plugin_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    @plugin_name = name
    @plugin_path = File.join("vendor/plugins/", name.underscore)
  end
  
  def manifest
    record do |m|
      m.directory @plugin_path
      m.directory "#{@plugin_path}/app/controllers/admin"
      m.directory "#{@plugin_path}/app/models"
      m.directory "#{@plugin_path}/app/views/admin"
      m.directory "#{@plugin_path}/config/alchemy"
      m.directory "#{@plugin_path}/locale"
      m.template("init.rb", "#{@plugin_path}/init.rb")
      m.template("config.yml", "#{@plugin_path}/config/alchemy/config.yml")
      m.template("authorization_rules.rb", "#{@plugin_path}/config/authorization_rules.rb")
      m.template("routes.rb", "#{@plugin_path}/config/routes.rb")
    end
  end

end
