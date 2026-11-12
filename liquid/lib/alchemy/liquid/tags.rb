# frozen_string_literal: true

module Alchemy
  module Liquid
    module Tags
      autoload :Arguments, "alchemy/liquid/tags/arguments"
      autoload :Cache, "alchemy/liquid/tags/cache"
      autoload :ElementView, "alchemy/liquid/tags/element_view"
      autoload :Elements, "alchemy/liquid/tags/elements"
      autoload :Ingredient, "alchemy/liquid/tags/ingredient"
      autoload :Menu, "alchemy/liquid/tags/menu"

      ALL = {
        "cache" => "Cache",
        "element_view" => "ElementView",
        "elements" => "Elements",
        "ingredient" => "Ingredient",
        "menu" => "Menu"
      }.freeze

      def self.register(environment)
        ALL.each { |name, klass| environment.register_tag(name, const_get(klass)) }
      end
    end
  end
end
