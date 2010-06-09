module Alchemy
  module Controller

    mattr_accessor :alchemy_plugins_settings
    mattr_accessor :current_language
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
      base.send :include, WaNotice
      base.send :helper_method, :plugin_conf, :alchemy_plugins_settings, :wa_plugins, :wa_plugin
    end

    def initialize
      super
      self.alchemy_plugins_settings = Hash.new
      plugins_settings_yaml = plugins_config_ymls
      plugins_settings_yaml.each do |settings|
        sets = YAML.load_file(settings)
        self.alchemy_plugins_settings[sets["name"]] = sets
      end
    end

    def self.multi_language?
      Configuration.parameter(:languages).size > 1
    end
    
    module ClassMethods
      
      def belongs_to_alchemy_plugin(plugin_name)
        send :layout, "wa_admin"
      end
      
    end

    module InstanceMethods

      def plugin_conf(plugin_name)
        alchemy_plugins_settings[plugin_name]["settings"]
      end

      # returns an array with all alchemy plugins including the alchemy core as first entry.
      # For your own plugin see config.yml in vendor/plugins/alchemy/config/alchemy folder
      def wa_plugins
        ymls = plugins_config_ymls
        plugins = []
        wa_config = ymls.detect { |c| c.include?('vendor/plugins/alchemy') }
        wa_config_yml = YAML.load_file(wa_config)
        if wa_config_yml
          wa_pl = wa_config_yml["wa_plugins"]
          plugins += wa_pl
        end
        ymls.delete(wa_config)
        begin
          ymls = ymls.sort(){ |x, y| YAML.load_file(x)['order'] <=> YAML.load_file(y)['order'] }
        rescue Exception => e
          Rails.logger.error(%(
            ++++++
            No order value in one of your plugins. Please check plugins
            ++++++
          ))
        end
        ymls.each do |y|
          plugin = YAML.load_file(y)
          plugins << plugin
        end
        return plugins
      end

      # returns the alchemy plugin found by name, or by hash of controller and action
      def wa_plugin(name)
        if name.is_a? String
          wa_plugins.detect{ |p| p["name"] == name }
        elsif name.is_a? Hash
          wa_plugins.detect do |p| 
            if !p["navigation"]["sub_navigation"].nil?
              p["navigation"]["sub_navigation"].detect do |s| 
                s["controller"] == name[:controller] && s["action"] == name[:action]
              end
            end
          end
        end
      end

    private

      def plugins_config_ymls
        Dir.glob("vendor/plugins/*/config/alchemy/config.yml")
      end

    end

  end
end
ActionController::Base.send(:include, Alchemy::Controller) if defined?(ActionController)
