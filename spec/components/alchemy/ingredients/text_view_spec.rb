# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::TextView, type: :component do
  let(:ingredient) { Alchemy::Ingredients::Text.new(value: "Hello World") }

  context "with blank link value" do
    context "and dom id set" do
      let(:ingredient) do
        Alchemy::Ingredients::Text.new(
          value: "Hello World",
          data: {
            dom_id: "se-anchor"
          }
        )
      end

      it "renders the dom_id and the value" do
        render_inline described_class.new(ingredient, disable_link: true)
        expect(page).to have_content("Hello World")
        expect(page).to have_selector('a[id="se-anchor"]')
      end
    end

    context "and no dom id set" do
      it "only renders the value" do
        render_inline described_class.new(ingredient)
        expect(page).to have_content("Hello World")
        expect(page).to_not have_selector("a")
      end
    end
  end

  context "with a link set" do
    let(:ingredient) do
      Alchemy::Ingredients::Text.new(
        value: "Hello World",
        data: {
          link: "http://google.com",
          link_title: "Foo",
          link_target: "_blank"
        }
      )
    end

    it "renders the linked value" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("Hello World")
      expect(page).to have_selector('a[title="Foo"][target="_blank"][href="http://google.com"]')
    end

    context "with link target set to '_blank'" do
      it "adds rel noopener noreferrer" do
        render_inline described_class.new(ingredient)
        expect(page).to have_selector(
          'a[title="Foo"][target="_blank"][href="http://google.com"][rel="noopener noreferrer"]'
        )
      end
    end

    context "with link target set to 'blank'" do
      it "sets target '_blank' and adds rel noopener noreferrer" do
        render_inline described_class.new(ingredient)
        expect(page).to have_selector(
          'a[title="Foo"][target="_blank"][href="http://google.com"][rel="noopener noreferrer"]'
        )
      end
    end

    context "with html_options given" do
      it "renders the linked with these options" do
        render_inline described_class.new(ingredient, html_options: {title: "Bar", class: "blue"})
        expect(page).to have_selector('a.blue[title="Bar"][target="_blank"]')
      end
    end

    context "but with options disable_link set to true" do
      context "and dom id set" do
        let(:ingredient) do
          Alchemy::Ingredients::Text.new(
            value: "Hello World",
            data: {
              dom_id: "se-anchor",
              link: "http://google.com",
              link_title: "Foo",
              link_target: "blank"
            }
          )
        end

        it "renders the dom_id and the value" do
          render_inline described_class.new(ingredient, disable_link: true)
          expect(page).to have_content("Hello World")
          expect(page).to have_selector('a[id="se-anchor"]')
        end
      end

      context "and no dom id set" do
        it "only renders the value" do
          render_inline described_class.new(ingredient, disable_link: true)
          expect(page).to have_content("Hello World")
          expect(page).to_not have_selector("a")
        end
      end
    end

    context "but with ingredient settings disable_link set to true" do
      before do
        allow(ingredient).to receive(:settings).and_return({disable_link: true})
      end

      it "only renders the value" do
        render_inline described_class.new(ingredient)
        expect(page).to have_content("Hello World")
        expect(page).to_not have_selector("a")
      end
    end

    context "and a dom id set" do
      let(:ingredient) do
        Alchemy::Ingredients::Text.new(
          value: "Hello World",
          data: {
            dom_id: "se-anchor",
            link: "http://google.com",
            link_title: "Foo",
            link_target: "blank"
          }
        )
      end

      it "renders the dom_id" do
        render_inline described_class.new(ingredient)
        expect(page).to have_selector('a[id="se-anchor"]')
      end
    end
  end
end
