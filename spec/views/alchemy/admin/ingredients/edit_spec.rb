# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/admin/ingredients/edit.html.erb" do
  before do
    view.extend Alchemy::Admin::FormHelper
    view.instance_variable_set(:@ingredient, ingredient)
  end

  context "for a picture ingredient" do
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

    let(:ingredient) { Alchemy::Ingredients::Picture.new(id: 1, picture: picture) }

    it "displays render_size selection if sizes present" do
      allow(ingredient).to receive(:settings).and_return({
        sizes: [
          ["Medium, 400x400", "400x400"],
          ["Small, 200x200", "200x200"],
        ],
      })

      render

      expect(rendered).to have_selector(".input.ingredient_render_size")
    end

    it "does not display render_size selection if srcset present" do
      # As the same sizes setting is used in another way here
      allow(ingredient).to receive(:settings).and_return({
        sizes: ["(min-width: 600px) 600px", "100vw"],
        srcset: ["200x100", "400x200", "600x300"],
      })

      render

      expect(rendered).to_not have_selector(".input.ingredient_render_size")
    end
  end
end
