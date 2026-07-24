# frozen_string_literal: true

require "rails_helper"
require "tmpdir"
require "alchemy/dev_support/live_reload_watcher"

RSpec.describe Alchemy::LiveReloadWatcher do
  # Both the subclass and the initializers ordered around the gem's own reach
  # into rails_live_reload internals that it does not document. An upgrade that
  # moves them has to fail here, rather than in a browser that quietly stops
  # reloading.
  describe "the rails_live_reload API this builds on" do
    it "provides the initializers the engine orders against" do
      expect(RailsLiveReload::Railtie.initializers.map(&:name)).to include(
        "rails_live_reload.middleware",
        "rails_live_reload.watcher",
        "rails_live_reload.configure_metrics"
      )
    end

    it "allows toggling the gem's own watcher off and on" do
      expect(RailsLiveReload).to respond_to(:enabled?)
      expect(RailsLiveReload.config).to respond_to(:enabled=)
    end

    it "exposes the watch patterns as regexps" do
      expect(RailsLiveReload.patterns.keys).to all(be_a(Regexp))
    end

    it "defines the methods the subclass overrides and relies on" do
      expect(RailsLiveReload::Watcher.instance_methods).to include(:build_tree, :files)
    end
  end

  describe "the configured patterns" do
    it "ignores the directories written while serving a request" do
      expect(RailsLiveReload.ignore_patterns).to include(
        %r{^node_modules/},
        %r{^(db|storage|coverage)/}
      )
    end

    it "ignores everything below spec except the dummy app's own sources" do
      pattern = RailsLiveReload.ignore_patterns.detect { |p| p.source.include?("spec") }

      expect("spec/dummy/log/development.log").to match(pattern)
      expect("spec/models/alchemy/page_spec.rb").to match(pattern)
      expect("spec/dummy/app/views/layouts/application.html.erb").to_not match(pattern)
    end
  end

  describe "#build_tree" do
    # The inherited constructor opens a socket and starts a listener thread.
    # Only the tree building is under test, so it is skipped.
    subject(:watcher) do
      described_class.allocate.tap { |w| w.instance_variable_set(:@files, {}) }
    end

    let(:root) { Pathname.new(Dir.mktmpdir).realpath }

    let(:fixtures) do
      %w[
        app/views/alchemy/pages/show.html.erb
        app/assets/builds/alchemy/admin.css
        app/javascript/alchemy_admin/components/node_select.js
        app/components/alchemy/foo_component.rb
        app/models/alchemy/page.rb
        config/locales/alchemy.en.yml
        vendor/javascript/sortable.min.js
        node_modules/sortablejs/dist/sortable.js
      ]
    end

    before do
      fixtures.each do |path|
        file = root.join(path)
        FileUtils.mkdir_p(file.dirname)
        FileUtils.touch(file)
      end
      allow(watcher).to receive(:root).and_return(root)
    end

    after { FileUtils.remove_entry(root) }

    def tracked
      watcher.build_tree
      watcher.files.keys.map { |file| Pathname.new(file).relative_path_from(root).to_s }
    end

    it "tracks only the files a watch pattern can match" do
      expect(tracked).to match_array(%w[
        app/views/alchemy/pages/show.html.erb
        app/assets/builds/alchemy/admin.css
        app/javascript/alchemy_admin/components/node_select.js
        app/components/alchemy/foo_component.rb
        config/locales/alchemy.en.yml
      ])
    end

    it "does not track node_modules" do
      expect(tracked).to_not include(a_string_matching("node_modules"))
    end

    it "does not track files no pattern can match" do
      expect(tracked).to_not include("app/models/alchemy/page.rb")
    end

    # The asset pattern expects a directory between `javascript/` and the file,
    # but the vendored bundles sit directly in `vendor/javascript`, so none of
    # them are watched. Rebuilding them does not reload the browser. This is
    # inherited from the gem's default configuration rather than intended, and
    # the assertion is here to record it until the pattern is widened.
    it "does not track the vendored bundles" do
      expect(tracked).to_not include("vendor/javascript/sortable.min.js")
    end

    it "records the mtime of every tracked file" do
      watcher.build_tree

      expect(watcher.files.values).to all(be_an(Integer))
    end

    context "when the application lives inside the engine root" do
      let(:app_root) { root.join("spec/dummy") }

      before do
        file = app_root.join("app/views/layouts/application.html.erb")
        FileUtils.mkdir_p(file.dirname)
        FileUtils.touch(file)
        allow(Rails.application).to receive(:root).and_return(app_root)
      end

      it "covers the application as well" do
        expect(tracked).to include("spec/dummy/app/views/layouts/application.html.erb")
      end
    end

    context "when the application lives outside the engine root" do
      before do
        allow(Rails.application).to receive(:root).and_return(Pathname.new("/somewhere/else"))
      end

      it "only tracks the engine" do
        expect { tracked }.to_not raise_error
        expect(tracked).to_not include(a_string_matching("somewhere/else"))
      end
    end
  end
end
