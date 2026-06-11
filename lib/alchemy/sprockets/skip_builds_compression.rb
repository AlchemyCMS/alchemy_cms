# frozen_string_literal: true

begin
  require "sprockets/sass_compressor"
rescue LoadError
  # Sprockets::SassCompressor is only defined if sassc-rails is present,
  # which is not the case in all environments (for example, when using Propshaft).
  # In that case, we can skip prepending our patch module.
end

module Alchemy
  module Sprockets
    # Alchemy ships pre-built, already-minified admin CSS in +app/assets/builds+
    # that uses modern CSS syntax (relative colors, +oklch()+ and friends). The
    # legacy SassC/libSass +css_compressor+ — the Sprockets default whenever
    # +sassc-rails+ is present (for example through Solidus) — re-parses every
    # +text/css+ asset as SCSS and raises on that syntax. These files are already
    # minified, so leave them untouched; all other stylesheets still get
    # compressed as before.
    module SkipBuildsCompression
      def call(input)
        builds_path = Alchemy::Engine.root.join("app/assets/builds").to_s
        if input[:filename].to_s.start_with?(builds_path)
          {data: input[:data]}
        else
          super
        end
      end

      ::Sprockets::SassCompressor.singleton_class.prepend(self)
    end
  end
end
