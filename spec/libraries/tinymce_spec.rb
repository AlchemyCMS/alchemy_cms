# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Tinymce do
    describe ".init" do
      subject { Tinymce.init }

      it "returns the default config" do
        is_expected.to eq(Tinymce.class_variable_get(:@@init))
      end
    end

    describe ".init=" do
      let(:another_config) { {theme_advanced_buttons3: "table"} }

      it "merges the default config with given config" do
        Tinymce.init = another_config
        expect(Tinymce.init).to include(another_config)
      end
    end

    describe ".preloadable_plugins" do
      subject { Tinymce.preloadable_plugins }

      before do
        Tinymce.plugins += ["foo"]
      end

      it "returns all plugins without default plugins" do
        is_expected.to eq %w[
          anchor
          charmap
          code
          directionality
          fullscreen
          link
          lists
          alchemy_link
          foo
        ]
      end
    end
  end
end
