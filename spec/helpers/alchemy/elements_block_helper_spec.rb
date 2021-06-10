# frozen_string_literal: true

require "rails_helper"

include Alchemy::ElementsHelper

module Alchemy
  describe "ElementsBlockHelper" do
    let(:page) { create(:alchemy_page, :public) }
    let(:element) { create(:alchemy_element, page: page, tag_list: "foo, bar") }
    let(:expected_wrapper_tag) { "div.#{element.name}##{element_dom_id(element)}" }

    describe "#element_view_for" do
      it "should yield an instance of ElementViewHelper" do
        expect { |b| element_view_for(element, &b) }.
          to yield_with_args(ElementsBlockHelper::ElementViewHelper)
      end

      it "should wrap its output in a DOM element" do
        expect(element_view_for(element)).
          to have_css expected_wrapper_tag
      end

      it "should change the wrapping DOM element according to parameters" do
        expect(element_view_for(element, tag: "span", class: "some_class", id: "some_id")).
          to have_css "span.some_class#some_id"
      end

      it "should include the element's tags in the wrapper DOM element" do
        expect(element_view_for(element)).
          to have_css "#{expected_wrapper_tag}[data-element-tags='foo bar']"
      end

      it "should use the provided tags formatter to format tags" do
        expect(element_view_for(element, tags_formatter: lambda { |tags| tags.join ", " })).
          to have_css "#{expected_wrapper_tag}[data-element-tags='foo, bar']"
      end

      it "should include the contents rendered by the block passed to it" do
        expect(element_view_for(element) do
          "view"
        end).to have_content "view"
      end

      context "when/if preview mode is not active" do
        subject { element_view_for(element) }
        it { is_expected.to have_css expected_wrapper_tag }
        it { is_expected.not_to have_css "#{expected_wrapper_tag}[data-alchemy-element]" }
      end

      context "when/if preview mode is active" do
        before do
          assign(:preview_mode, true)
          assign(:page, page)
        end

        subject { helper.element_view_for(element) }
        it { is_expected.to have_css "#{expected_wrapper_tag}[data-alchemy-element='#{element.id}']" }
      end
    end

    describe "ElementsBlockHelper::ElementViewHelper" do
      let(:scope) { double }
      subject { ElementsBlockHelper::ElementViewHelper.new(scope, element: element) }

      it "should have a reference to the specified element" do
        subject.element == element
      end

      describe "#render" do
        context "with element having contents" do
          let(:element) { create(:alchemy_element, :with_contents) }
          let(:content) { element.content_by_name(:headline) }

          it "delegates to Rails' render helper" do
            expect(scope).to receive(:render).with(content, {
              options: {
                foo: "bar",
              },
              html_options: {},
            })
            subject.render(:headline, foo: "bar")
          end
        end

        context "with element having ingredients" do
          let(:element) { create(:alchemy_element, :with_ingredients) }
          let(:ingredient) { element.ingredient_by_role(:headline) }

          it "delegates to Rails' render helper" do
            expect(scope).to receive(:render).with(ingredient, {
              options: {
                foo: "bar",
              },
              html_options: {},
            })
            subject.render(:headline, foo: "bar")
          end
        end
      end

      describe "#content" do
        it "should delegate to the element's #content_by_name method" do
          expect(element).to receive(:content_by_name).with(:title)
          subject.content :title
        end
      end

      describe "#ingredient" do
        context "with element having contents" do
          it "should delegate to the element's #ingredient method" do
            expect(element).to receive(:ingredient).with(:title)
            subject.ingredient(:title)
          end
        end

        context "with element having ingredients" do
          let(:element) { create(:alchemy_element, :with_ingredients) }
          let(:ingredient) { element.ingredients.first }

          it "should return the ingredients value" do
            expect(ingredient).to receive(:value).and_call_original
            subject.ingredient(:headline)
          end
        end
      end

      describe "#has?" do
        context "with element having contents" do
          it "should delegate to the element's #has_ingredient? method" do
            expect(element).to receive(:has_ingredient?).with(:title)
            subject.has?(:title)
          end
        end

        context "with element having ingredients" do
          let(:element) { create(:alchemy_element, :with_ingredients) }
          let(:ingredient) { element.ingredients.first }

          it "should delegate to the element's #has_value? method" do
            expect(element).to receive(:has_value_for?).with(:headline)
            subject.has?(:headline)
          end
        end
      end

      describe "#essence" do
        it "should provide the specified content essence" do
          expect(subject).to receive(:content).with(:title) do
            mock_model("Content", essence: mock_model("EssenceText"))
          end

          subject.essence :title
        end
      end
    end
  end
end
