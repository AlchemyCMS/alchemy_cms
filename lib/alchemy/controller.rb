module Alchemy
  module Controller

    mattr_accessor :alchemy_plugins_settings
    mattr_accessor :current_language
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
      base.send :include, Alchemy::Notice
      base.send :helper_method, :plugin_conf, :alchemy_plugins_settings, :alchemy_plugins, :alchemy_plugin
    end
    
    def initialize
      super
      self.alchemy_plugins_settings = {}
      plugins_config_paths.each do |settings_file|
        settings = YAML.load_file(settings_file)
				Rails.logger.info("\n+++++ Registered #{settings["name"]} as Alchemy plugin.")
        self.alchemy_plugins_settings[settings["name"]] = settings
      end
    end
    
    module ClassMethods
      
      def belongs_to_alchemy_plugin(plugin_name)
        send :layout, "admin"
      end
      
    end

    module InstanceMethods
      
      def plugin_conf(plugin_name)
        alchemy_plugins_settings[plugin_name]["settings"]
      end

      # returns an array with all alchemy plugins including the alchemy core as first entry.
      # For your own plugin see config.yml in vendor/plugins/alchemy/config/alchemy folder
      def alchemy_plugins
        yml_paths = plugins_config_paths
				plugins = Alchemy::Configuration.get("alchemy_plugins")
        begin
          yml_paths = yml_paths.sort(){ |x, y| YAML.load_file(x)['order'] <=> YAML.load_file(y)['order'] }
        rescue Exception => e
          Rails.logger.error(%(
            ++++++
            #{e}
            No order value in one of your plugins. Please check plugin config!
            ++++++
          ))
        end
        yml_paths.map { |y| plugins << YAML.load_file(y) }
        plugins
      end

      # returns the alchemy plugin found by name, or by hash of controller and action
      def alchemy_plugin(name)
        if name.is_a? String
          alchemy_plugins.detect{ |p| p["name"] == name }
        elsif name.is_a? Hash
          alchemy_plugins.detect do |p| 
            if !p["navigation"]["sub_navigation"].nil?
              p["navigation"]["sub_navigation"].detect do |s| 
                s["controller"] == name[:controller] && s["action"] == name[:action]
              end
            end
          end
        end
      end

    private

      def plugins_config_paths
				Dir.glob("vendor/plugins/*[^alchemy]/config/alchemy/config.yml")
      end

    end

  end
end
ActionController::Base.send(:include, Alchemy::Controller) if defined?(ActionController)
