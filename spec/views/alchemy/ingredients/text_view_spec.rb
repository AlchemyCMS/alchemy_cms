# frozen_string_literal: true

require "rails_helper"

describe "alchemy/ingredients/_text_view" do
  let(:ingredient) { Alchemy::Ingredients::Text.new(value: "Hello World") }

  context "with blank link value" do
    it "only renders the value" do
      render ingredient
      expect(rendered).to have_content("Hello World")
      expect(rendered).to_not have_selector("a")
    end
  end

  context "with a link set" do
    let(:ingredient) do
      Alchemy::Ingredients::Text.new(
        value: "Hello World",
        data: {
          link: "http://google.com",
          link_title: "Foo",
          link_target: "blank",
        },
      )
    end

    it "renders the linked value" do
      render ingredient
      expect(rendered).to have_content("Hello World")
      expect(rendered).to have_selector('a[title="Foo"][target="_blank"][data-link-target="blank"][href="http://google.com"]')
    end

    context "with html_options given" do
      it "renders the linked with these options" do
        render ingredient, html_options: { title: "Bar", class: "blue" }
        expect(rendered).to have_selector('a.blue[title="Bar"][target="_blank"][data-link-target="blank"]')
      end
    end

    context "but with options disable_link set to true" do
      it "only renders the value" do
        render ingredient, options: { disable_link: true }
        expect(rendered).to have_content("Hello World")
        expect(rendered).to_not have_selector("a")
      end
    end

    context "but with ingredient settings disable_link set to true" do
      before do
        allow(ingredient).to receive(:settings).and_return({ disable_link: true })
      end

      it "only renders the value" do
        render ingredient
        expect(rendered).to have_content("Hello World")
        expect(rendered).to_not have_selector("a")
      end
    end
  end
end
