# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe EssenceRichtext do
    let(:element) { create(:alchemy_element, name: "article") }
    let(:content) { Alchemy::Content.new(name: "text", element: element) }
    let(:essence) do
      Alchemy::EssenceRichtext.new(
        content: content,
        body: "<h1 style=\"color: red;\">Hello!</h1><p class=\"green\">Welcome to Peters Petshop.</p>"
      )
    end

    context "without a content" do
      let(:essence) do
        Alchemy::EssenceRichtext.new(
          body: "<h1 style=\"color: red;\">Hello!</h1><p class=\"green\">Welcome to Peters Petshop.</p>"
        )
      end

      it "can still be created with no odd error" do
        expect { essence.save! }.not_to raise_exception
      end
    end

    it_behaves_like "an essence" do
      let(:essence) { EssenceRichtext.new(content: content) }
      let(:ingredient_value) { "<h1 style=\"color: red;\">Hello!</h1><p class=\"green\">Welcome to Peters Petshop.</p>" }
    end

    it "should save a HTML tag free version of body column" do
      essence.save
      expect(essence.stripped_body).to eq("Hello!Welcome to Peters Petshop.")
    end

    it "should save a sanitized version of body column" do
      essence.save
      expect(essence.sanitized_body).to eq("<h1>Hello!</h1><p class=\"green\">Welcome to Peters Petshop.</p>")
    end

    context "when class is not part of the allowed attributes" do
      let(:element) { create(:alchemy_element, name: "text") }
      let(:content) { Alchemy::Content.new(name: "text", element: element) }

      it "should save a sanitized version of body column" do
        essence.save
        expect(essence.sanitized_body).to eq("Hello!<p>Welcome to Peters Petshop.</p>")
      end
    end

    it "should save a HTML tag free version of body column" do
      essence.save
      expect(essence.stripped_body).to eq("Hello!Welcome to Peters Petshop.")
    end

    it "has tinymce enabled" do
      expect(essence.has_tinymce?).to eq(true)
    end
  end
end
