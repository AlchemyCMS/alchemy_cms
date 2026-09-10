# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy admin importmap" do
  let(:javascript_root) { Alchemy::Engine.root.join("app/javascript") }
  let(:packages) { Alchemy.importmap.packages }

  # Modules pinned to their own source file (rather than to the admin bundle)
  # exist so host engines can import a single module standalone.
  let(:standalone_sources) do
    packages.values.map { javascript_root.join(_1.path) }.select(&:file?)
  end

  def bare_imports(file)
    file.read.scan(/(?:\bfrom|\bimport)\s+"([^"]+)"/).flatten.reject do |specifier|
      specifier.start_with?(".", "/")
    end
  end

  # The admin bundle inlines these imports, so an unpinned one never breaks
  # Alchemy itself. It only breaks the host engine, at runtime, with a bare
  # specifier error that points at Alchemy's source rather than at the pin.
  it "pins everything the standalone modules import" do
    queue = standalone_sources.dup
    visited = []
    missing = Hash.new { |hash, key| hash[key] = [] }

    while (file = queue.shift)
      next if visited.include?(file)
      visited << file

      bare_imports(file).each do |specifier|
        package = packages[specifier]
        next missing[file.relative_path_from(javascript_root).to_s] << specifier unless package

        dependency = javascript_root.join(package.path)
        queue << dependency if dependency.file?
      end
    end

    expect(missing).to be_empty, lambda {
      missing.map { |source, specifiers| "#{source} imports unpinned #{specifiers.uniq.join(", ")}" }.join("\n")
    }
  end
end
