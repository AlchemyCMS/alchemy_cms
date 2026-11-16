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

    describe ".cache_suffix" do
      let(:view_context) { ActionController::Base.helpers }

      subject { Tinymce.cache_suffix(view_context) }

      it { is_expected.to match(/\A[0-9a-f]{8}\z/) }

      it "changes when a skin stylesheet changes" do
        suffix = Tinymce.cache_suffix(view_context)
        allow(view_context).to receive(:asset_path).and_return("changed")
        expect(Tinymce.cache_suffix(view_context)).to_not eq(suffix)
      end

      it "changes when a custom plugin changes" do
        suffix = Tinymce.cache_suffix(view_context)
        allow(Tinymce).to receive(:preloadable_plugins).and_return(%w[foo])
        allow(view_context).to receive(:asset_path).and_call_original
        allow(view_context).to receive(:asset_path)
          .with("tinymce/plugins/foo/plugin.min.js")
          .and_return("/assets/tinymce/plugins/foo/plugin.min-1234abcd.js")
        expect(Tinymce.cache_suffix(view_context)).to_not eq(suffix)
      end
    end

    describe ".preloadable_plugins" do
      subject { Tinymce.preloadable_plugins }

      before do
        Tinymce.plugins += ["foo"]
      end

      after do
        Tinymce.plugins = Tinymce::DEFAULT_PLUGINS
      end

      it "returns all plugins without default plugins" do
        is_expected.to eq %w[
          foo
        ]
      end
    end
  end
end
