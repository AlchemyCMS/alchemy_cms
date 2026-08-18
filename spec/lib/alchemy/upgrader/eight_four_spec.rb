# frozen_string_literal: true

require "rails_helper"
require "alchemy/upgrader"

RSpec.describe Alchemy::Upgrader::EightFour do
  let(:upgrader) { Alchemy::Upgrader["8.4"] }

  around do |example|
    Alchemy::Shell.silence!
    example.run
    Alchemy::Shell.verbose!
  end

  describe "#add_dragonfly_gem" do
    subject { upgrader.add_dragonfly_gem }

    context "when the storage adapter is dragonfly" do
      before do
        allow(Alchemy).to receive(:storage_adapter) do
          Alchemy::StorageAdapter.new(:dragonfly)
        end
      end

      it "adds the dragonfly gem to the bundle" do
        expect(upgrader).to receive(:run).with(%(bundle add dragonfly --version "~> 1.4"))
        subject
      end
    end

    context "when the storage adapter is active_storage" do
      before do
        allow(Alchemy).to receive(:storage_adapter) do
          Alchemy::StorageAdapter.new(:active_storage)
        end
      end

      it "does not add the dragonfly gem" do
        expect(upgrader).not_to receive(:run)
        subject
      end
    end
  end

  describe "#upgrade_nested_elements_rendering" do
    subject { upgrader.upgrade_nested_elements_rendering }

    let(:partial_path) { Rails.root.join("app/views/alchemy/elements/_gallery.html.erb").to_s }

    before do
      allow(Dir).to receive(:glob).and_return([partial_path])
      allow(File).to receive(:file?).and_return(true)
      allow(File).to receive(:read).and_return(partial_content)
      allow(upgrader).to receive(:gsub_file)
    end

    context "when an element partial renders via the nested_elements association" do
      let(:partial_content) do
        <<~ERB
          <%= element_view_for(gallery) do |el| %>
            <%= render gallery.nested_elements.published %>
          <% end %>
        ERB
      end

      it "rewrites the partial to render through the block helper" do
        expect(upgrader).to receive(:gsub_file)
          .with(partial_path, instance_of(Regexp), "render el.nested_elements")
        subject
      end

      it "adds a todo about the change" do
        expect(upgrader).to receive(:todo).with(kind_of(String), kind_of(String))
        subject
      end
    end

    context "when the block variable was renamed by the developer" do
      let(:partial_content) do
        <<~ERB
          <%= element_view_for(gallery) do |item| %>
            <%= render gallery.nested_elements %>
          <% end %>
        ERB
      end

      it "rewrites using the actual block variable name" do
        expect(upgrader).to receive(:gsub_file)
          .with(partial_path, instance_of(Regexp), "render item.nested_elements")
        subject
      end
    end

    context "when a partial renders nested elements outside an element_view_for block" do
      let(:partial_content) { "<%= render gallery.nested_elements %>" }

      it "does not rewrite it automatically" do
        expect(upgrader).not_to receive(:gsub_file)
        subject
      end

      it "adds a todo asking to update it manually" do
        expect(upgrader).to receive(:todo).with(kind_of(String), kind_of(String))
        subject
      end
    end

    context "when element partials already render through the block helper" do
      let(:partial_content) do
        <<~ERB
          <%= element_view_for(gallery) do |el| %>
            <%= render el.nested_elements %>
          <% end %>
        ERB
      end

      it "does not rewrite anything" do
        expect(upgrader).not_to receive(:gsub_file)
        subject
      end

      it "does not add a todo" do
        expect(upgrader).not_to receive(:todo)
        subject
      end
    end
  end
end
