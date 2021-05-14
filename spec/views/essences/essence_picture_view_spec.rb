# frozen_string_literal: true

require "rails_helper"

describe "alchemy/essences/_essence_picture_view" do
  let(:picture) { build_stubbed(:alchemy_picture) }
  let(:essence) { build_stubbed(:alchemy_essence_picture, picture: picture) }
  let(:content) { build_stubbed(:alchemy_content, essence: essence) }

  it "renders when passing only the content" do
    render content, content: content
    expect(rendered).to have_selector("img")
  end
end
