# frozen_string_literal: true

require "rails_helper"
include Alchemy::BaseHelper

module Alchemy
  describe ElementsHelper do
    let(:element) { create(:alchemy_element, name: "headline") }

    before do
      assign(:page, element&.page)
      allow_any_instance_of(Element).to receive(:store_page).and_return(true)
    end

    describe "#render_element" do
      subject { render_element(element) }

      context "with nil element" do
        let(:element) { nil }

        it { is_expected.to be_nil }
      end

      context "with element record given" do
        let(:element) do
          create(:alchemy_element, :with_contents, name: "headline")
        end

        it "renders the element's view partial" do
          is_expected.to have_selector("##{element.name}_#{element.id}")
        end

        context "with element view partial not found" do
          let(:element) { build_stubbed(:alchemy_element, name: "not_present") }

          it "renders the view not found partial" do
            is_expected.to match(/Missing view for not_present element/)
          end
        end
      end

      context "with options given" do
        subject { render_element(element, locals: { some: "thing" }) }

        it "passes them into the view" do
          is_expected.to match(/thing/)
        end
      end

      context "with counter given" do
        subject { render_element(element, {}, 2) }

        it "passes them into the view" do
          is_expected.to match(/2\./)
        end
      end
    end

    describe "#element_dom_id" do
      subject { helper.element_dom_id(element) }

      it "should render a unique dom id for element" do
        is_expected.to eq("#{element.name}_#{element.id}")
      end
    end

    describe "#render_elements" do
      subject { helper.render_elements(options) }

      let(:page) { create(:alchemy_page, :public) }
      let!(:element) { create(:alchemy_element, name: "headline", page_version: page.public_version) }
      let!(:another_element) { create(:alchemy_element, page_version: page.public_version) }

      context "without any options" do
        let(:options) { {} }

        it "should render all elements from current pages public version." do
          is_expected.to have_selector("##{element.name}_#{element.id}")
          is_expected.to have_selector("##{another_element.name}_#{another_element.id}")
        end

        context "in preview_mode" do
          let!(:draft_element) { create(:alchemy_element, name: "headline", page_version: page.draft_version) }

          before do
            assign(:preview_mode, true)
          end

          it "page draft version is used" do
            is_expected.to have_selector("##{draft_element.name}_#{draft_element.id}")
          end
        end
      end

      context "with from_page option" do
        context "is a page object" do
          let(:another_page) { create(:alchemy_page, :public) }

          let(:options) do
            { from_page: another_page }
          end

          let!(:element) { create(:alchemy_element, name: "headline", page: another_page, page_version: another_page.public_version) }
          let!(:another_element) { create(:alchemy_element, page: another_page, page_version: another_page.public_version) }

          it "should render all elements from that page." do
            is_expected.to have_selector("##{element.name}_#{element.id}")
            is_expected.to have_selector("##{another_element.name}_#{another_element.id}")
          end

          context "in preview_mode" do
            let!(:draft_element) { create(:alchemy_element, name: "headline", page_version: another_page.draft_version) }

            before do
              assign(:preview_mode, true)
            end

            it "page draft version is used" do
              is_expected.to have_selector("##{draft_element.name}_#{draft_element.id}")
            end
          end
        end

        context "if from_page is nil" do
          let(:options) do
            { from_page: nil }
          end

          it { is_expected.to be_empty }
        end
      end

      context "with option separator given" do
        let(:options) { {separator: "<hr>"} }

        it "joins element partials with given string" do
          is_expected.to have_selector("hr")
        end
      end

      context "with custom elements finder" do
        let(:options) do
          { finder: CustomNewsElementsFinder.new }
        end

        it "uses that to load elements to render" do
          is_expected.to have_selector("#news_1001")
        end
      end
    end

    describe "#element_preview_code_attributes" do
      subject { helper.element_preview_code_attributes(element) }

      context "in preview_mode" do
        before { assign(:preview_mode, true) }

        it "should return the data-alchemy-element HTML attribute for element" do
          is_expected.to eq({"data-alchemy-element" => element.id})
        end
      end

      context "not in preview_mode" do
        it "should return an empty hash" do
          is_expected.to eq({})
        end
      end
    end

    describe "#element_preview_code" do
      subject { helper.element_preview_code(element) }

      context "in preview_mode" do
        before { assign(:preview_mode, true) }

        it "should return the data-alchemy-element HTML attribute for element" do
          is_expected.to eq(" data-alchemy-element=\"#{element.id}\"")
        end
      end

      context "not in preview_mode" do
        it "should not return the data-alchemy-element HTML attribute" do
          is_expected.not_to eq(" data-alchemy-element=\"#{element.id}\"")
        end
      end
    end

    describe "#element_tags" do
      subject { element_tags(element, options) }

      let(:element) { build_stubbed(:alchemy_element) }
      let(:options) { {} }

      context "element having tags" do
        before { element.tag_list = "peter, lustig" }

        context "with no formatter lambda given" do
          it "should return tag list as HTML data attribute" do
            is_expected.to eq(" data-element-tags=\"peter lustig\"")
          end
        end

        context "with a formatter lambda given" do
          let(:options) { {formatter: ->(tags) { tags.join ", " }} }

          it "should return a properly formatted HTML data attribute" do
            is_expected.to eq(" data-element-tags=\"peter, lustig\"")
          end
        end
      end

      context "element not having tags" do
        it { is_expected.to be_blank }
      end
    end
  end
end
