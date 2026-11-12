# frozen_string_literal: true

require "generators/alchemy/elements/elements_generator"
require "generators/alchemy/page_layouts/page_layouts_generator"

module Alchemy
  module Liquid
    # Adds Liquid templates to Alchemy's view generators, so
    #
    #   bin/rails g alchemy:elements --template-engine liquid
    #   bin/rails g alchemy:page_layouts --template-engine liquid
    #
    # generate +.html.liquid+ partials. The generators pick their templates
    # by engine name, so this only extends their template source paths.
    module Generators
      TEMPLATES_ROOT = File.expand_path("../../generators/alchemy/liquid", __dir__)

      {
        Alchemy::Generators::ElementsGenerator => "elements",
        Alchemy::Generators::PageLayoutsGenerator => "page_layouts"
      }.each do |generator, dir|
        path = File.join(TEMPLATES_ROOT, dir, "templates")
        generator.source_paths << path unless generator.source_paths.include?(path)
      end
    end
  end
end
