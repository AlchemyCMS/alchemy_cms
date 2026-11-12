# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy::Liquid::Filters#picture_url", type: :helper do
  let(:ingredient) { build_stubbed(:alchemy_ingredient_picture) }

  it "returns the picture url of a picture ingredient" do
    allow(ingredient).to receive(:picture_url).with({}).and_return("/pictures/1.jpg")
    expect(render_liquid("{{ image | picture_url }}", image: ingredient)).to eq("/pictures/1.jpg")
  end

  it "passes keyword arguments as options" do
    allow(ingredient).to receive(:picture_url).with({size: "300x200", crop: true}).and_return("/pictures/1-crop.jpg")
    html = render_liquid('{{ image | picture_url: size: "300x200", crop: true }}', image: ingredient)
    expect(html).to eq("/pictures/1-crop.jpg")
  end

  it "returns nothing for other ingredients" do
    text = build_stubbed(:alchemy_ingredient_text)
    expect(render_liquid("{{ text | picture_url }}", text: text)).to eq("")
  end
end
