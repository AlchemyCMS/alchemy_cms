# frozen_string_literal: true

require "digest"

module Alchemy
  module Liquid
    # ActionView template handler for +.liquid+ files.
    #
    # Templates are looked up by ActionView like any other template, so
    # +render_element+, +render_page_layout+, fragment caching and template
    # digests work as usual.
    #
    # Each source is parsed once and cached by its digest. The template is
    # rendered with the view context in the +:view+ register, which is what
    # the Alchemy tags and filters use to delegate to Alchemy's helpers.
    module Handler
      PARSE_OPTIONS = {error_mode: :strict, line_numbers: true}.freeze
      CACHE = Concurrent::Map.new

      class << self
        # Called by ActionView when compiling the template.
        def call(template, source)
          digest = Digest::SHA256.hexdigest(source)
          "Alchemy::Liquid::Handler.render(#{digest.dump}, #{source.dump}, self, local_assigns, #{template.virtual_path.to_s.dump})"
        end

        # @param digest [String] digest of the template source
        # @param source [String] the Liquid template source
        # @param view [ActionView::Base] the view context
        # @param locals [Hash] the locals passed to the template
        # @param name [String] the virtual path of the template, used in error messages
        def render(digest, source, view, locals, name = nil)
          template = parse(digest, source)
          assigns = Alchemy::Liquid.to_drop(locals.to_h)
          output = template.render!(assigns, registers: {view: view}, strict_filters: true)
          output.html_safe
        rescue ::Liquid::Error => error
          error.template_name ||= name.presence
          raise
        end

        def parse(digest, source)
          cache.compute_if_absent(digest) do
            ::Liquid::Template.parse(source, environment: Alchemy::Liquid.environment, **PARSE_OPTIONS)
          end
        end

        def clear_cache!
          cache.clear
        end

        def cache
          CACHE
        end
      end
    end
  end
end
