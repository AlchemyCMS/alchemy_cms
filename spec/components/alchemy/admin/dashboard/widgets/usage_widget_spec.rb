# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::UsageWidget, type: :component do
  subject(:widget) { described_class.new }

  describe "abstract subclass hooks" do
    it "raises NotImplementedError for #header_text" do
      expect { widget.send(:header_text, total: 0) }.to raise_error(NotImplementedError)
    end

    %i[definitions public_counts draft_counts].each do |method|
      it "raises NotImplementedError for ##{method}" do
        expect { widget.send(method) }.to raise_error(NotImplementedError)
      end
    end

    %i[entry_label entry_icon].each do |method|
      it "raises NotImplementedError for ##{method}" do
        expect { widget.send(method, double) }.to raise_error(NotImplementedError)
      end
    end

    it "provides a default #tooltip_content built from #entry_label" do
      entry = Alchemy::Admin::Dashboard::Widgets::UsageWidget::Entry.new(
        name: "foo", public_count: 2, draft_count: 3, definition: nil
      )
      allow(widget).to receive(:entry_label).with(entry).and_return("Foo")
      expect(widget.send(:tooltip_content, entry))
        .to eq("Foo: 2 #{Alchemy.t(:published)}, 3 #{Alchemy.t(:draft)}")
    end
  end
end
