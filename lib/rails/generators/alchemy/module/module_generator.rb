require 'rails'

module Alchemy
  module Generators
    class ModuleGenerator < ::Rails::Generators::Base
      desc "This generator generates an Alchemy module for you."
      argument :module_name, banner: "your_module_name"
      source_root File.expand_path('templates', __dir__)

      def init
        @module_name = module_name.downcase
        @class_name = @module_name.singularize.classify
        @controller_name = @module_name.tableize
        @controller_class = @controller_name.classify.pluralize
      end

      def make_route
        route "namespace :admin do\n    resources :#{@controller_name}\n  end"
      end

      def copy_templates
        template "controller.rb.tt", "app/controllers/admin/#{@controller_name}_controller.rb"
        template "ability.rb.tt", "app/models/#{@module_name}_ability.rb"
        template "module_config.rb.tt", "config/initializers/alchemy_#{@module_name}.rb"
      end
    end
  end
end
