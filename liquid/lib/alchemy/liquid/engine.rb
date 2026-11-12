# frozen_string_literal: true

require "alchemy_cms"

module Alchemy
  module Liquid
    class Engine < ::Rails::Engine
      engine_name "alchemy_liquid"

      initializer "alchemy_liquid.template_handler" do
        ActiveSupport.on_load(:action_view) do
          ActionView::Template.register_template_handler(:liquid, Alchemy::Liquid::Handler)
        end
      end

      # Lets fragment cache digests of page layouts include their element
      # partials, the same way Alchemy does for erb, haml and slim.
      initializer "alchemy_liquid.dependency_tracker" do
        ActionView::DependencyTracker.register_tracker(:liquid, Alchemy::CacheDigests::TemplateTracker)
      end

      # Templates are recompiled on code reload, so cached parse trees
      # of the previous sources are not needed anymore.
      config.to_prepare do
        Alchemy::Liquid::Handler.clear_cache!
      end

      generators do
        require "alchemy/liquid/generators"
      end
    end
  end
end
