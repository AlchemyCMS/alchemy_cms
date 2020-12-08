# frozen_string_literal: true

require "rails_helper"

describe "alchemy/admin/essence_pictures/edit.html.erb" do
  let(:image) do
    fixture_file_upload(
      File.expand_path("../../../../fixtures/500x500.png", __dir__),
      "image/png"
    )
  end

  let(:picture) do
    create(:alchemy_picture, {
      image_file: image,
      name: "img",
      image_file_name: "img.png",
    })
  end

  let(:content) { Alchemy::Content.new(id: 1) }
  let(:essence) { Alchemy::EssencePicture.new(id: 1, content: content, picture: picture) }

  before do
    view.extend Alchemy::Admin::FormHelper
    view.instance_variable_set(:@essence_picture, essence)
    view.instance_variable_set(:@content, content)
  end

  it "displays render_size selection if sizes present" do
    allow(content).to receive(:settings).and_return({
      sizes: [
        ["Medium, 400x400", "400x400"],
        ["Small, 200x200", "200x200"],
      ],
    })

    render

    expect(rendered).to have_selector(".input.essence_picture_render_size")
  end

  it "does not display render_size selection if srcset present" do
    # As the same sizes setting is used in another way here
    allow(content).to receive(:settings).and_return({
      sizes: ["(min-width: 600px) 600px", "100vw"],
      srcset: ["200x100", "400x200", "600x300"],
    })

    render

    expect(rendered).to_not have_selector(".input.essence_picture_render_size")
  end

  it "displays gravity selection if gravity setting present" do
    allow(content).to receive(:settings).and_return({
      gravity: true, # Could also be a hash that overrides default_gravity
    })

    render

    expect(rendered).to have_selector(".input.essence_picture_render_gravity_size")
    expect(rendered).to have_selector(".input.essence_picture_render_gravity_x")
    expect(rendered).to have_selector(".input.essence_picture_render_gravity_y")
  end
end
