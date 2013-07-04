module Alchemy
  module Modules

    @@alchemy_modules = YAML.load_file(File.join(File.dirname(__FILE__), '../..', 'config/alchemy', 'modules.yml'))

    def self.included(base)
      base.send :helper_method, :alchemy_modules, :module_definition_for
    end

    def alchemy_modules
      @@alchemy_modules
    end

    def module_definition_for(name)
      if name.is_a? String
        alchemy_modules.detect { |p| p["name"] == name }
      elsif name.is_a? Hash
        alchemy_modules.detect do |alchemy_module|
          alchemy_module.stringify_keys!
          name.symbolize_keys!
          module_navi = alchemy_module["navigation"].stringify_keys
          if module_navi["sub_navigation"]
            module_navi["sub_navigation"].map(&:stringify_keys).detect do |subnavi|
              subnavi["controller"].gsub(/\A\//, '') == name[:controller] && subnavi["action"] == name[:action]
            end
          end
        end
      else
        raise "Could not find module definition for #{name}"
      end
    end

    def self.register_module(module_definition)
      @@alchemy_modules << module_definition.stringify_keys
    end

  end
end
