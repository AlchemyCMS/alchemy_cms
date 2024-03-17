require "rails_helper"

RSpec.describe Alchemy::Admin::Message, type: :component do
  before do
    render
  end

  subject(:render) do
    render_inline described_class.new(message)
  end

  let(:message) { "This is a message" }

  it "renders an alchemy-message with default type" do
    expect(page).to have_css('alchemy-message[type="info"]', text: "This is a message")
  end

  it "renders a not-dismissable alchemy-message by default" do
    expect(page).to_not have_css "alchemy-message[dismissable]"
  end

  context "with message given as block" do
    subject(:render) do
      render_inline described_class.new do
        "<p>This is a block message</p>".html_safe
      end
    end

    it "renders an alchemy-message with default type" do
      expect(page).to have_css('alchemy-message[type="info"] > p', text: "This is a block message")
    end
  end

  context "with type given" do
    subject(:render) do
      render_inline described_class.new(message, type: type)
    end

    let(:type) { "alert" }

    it "renders an alchemy-message with given type" do
      expect(page).to have_css 'alchemy-message[type="alert"]'
    end
  end

  context "with dismissable set to true" do
    subject(:render) do
      render_inline described_class.new(message, dismissable: true)
    end

    it "renders an dismissable alchemy-message" do
      expect(page).to have_css "alchemy-message[dismissable]"
    end
  end
end
