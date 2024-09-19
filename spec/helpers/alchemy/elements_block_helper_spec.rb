# frozen_string_literal: true

require "rails_helper"

include Alchemy::ElementsHelper # rubocop:disable Style/MixinUsage

module Alchemy
  describe ElementsBlockHelper do
    let(:page) { create(:alchemy_page, :public) }
    let(:element) { create(:alchemy_element, page: page, tag_list: "foo, bar") }

    describe "#element_view_for" do
      it "should yield an instance of ElementViewHelper" do
        expect { |b| element_view_for(element, &b) }
          .to yield_with_args(ElementsBlockHelper::ElementViewHelper)
      end

      it "should wrap its output in a DOM element" do
        expect(element_view_for(element))
          .to have_css "div"
      end

      context "when id and class options are given" do
        it "should change the wrapping DOM element according to parameters" do
          expect(element_view_for(element, tag: "span", class: "some_class", id: "some_id"))
            .to have_css "span.some_class#some_id"
        end
      end

      it "should include the element's tags in the wrapper DOM element" do
        expect(element_view_for(element))
          .to have_css "div[data-element-tags='foo bar']"
      end

      it "should use the provided tags formatter to format tags" do
        expect(element_view_for(element, tags_formatter: lambda { |tags| tags.join ", " }))
          .to have_css "div[data-element-tags='foo, bar']"
      end

      it "should include the ingredients rendered by the block passed to it" do
        expect(element_view_for(element) do
          "view"
        end).to have_content "view"
      end

      context "when/if preview mode is not active" do
        subject { element_view_for(element) }
        it { is_expected.to have_css "div" }
        it { is_expected.not_to have_css "div[data-alchemy-element]" }
      end

      context "when/if preview mode is active" do
        include_context "in preview mode"

        subject { helper.element_view_for(element) }
        it { is_expected.to have_css "div[data-alchemy-element='#{element.id}']" }
      end
    end

    describe "ElementsBlockHelper::ElementViewHelper" do
      let(:scope) { double }
      subject { ElementsBlockHelper::ElementViewHelper.new(scope, element: element) }

      it "should have a reference to the specified element" do
        subject.element == element
      end

      describe "#render" do
        let(:scope) { double(render: "<alchemy-ingredient>") }

        context "with element having ingredients" do
          let(:element) { create(:alchemy_element, name: :header, autogenerate_ingredients: true) }
          let(:ingredient) { element.ingredient_by_role(:image) }

          it "passes options and html_options to view component class" do
            expect(ingredient).to receive(:as_view_component).with(
              options: {disable_link: true},
              html_options: {class: "foo"}
            )
            subject.render(:image, {disable_link: true}, {class: "foo"})
          end

          it "delegates to Rails' render helper" do
            expect(scope).to receive(:render).with(
              an_instance_of(Alchemy::Ingredients::PictureView)
            )
            subject.render(:image)
          end
        end
      end

      describe "#value" do
        let(:element) { create(:alchemy_element, :with_ingredients) }
        let(:ingredient) { element.ingredients.first }

        it "should return the ingredients value" do
          expect(element).to receive(:value_for).and_call_original
          subject.value(:headline)
        end
      end

      describe "#has?" do
        context "with element having ingredients" do
          let(:element) { create(:alchemy_element, :with_ingredients) }
          let(:ingredient) { element.ingredients.first }

          it "should delegate to the element's #has_value? method" do
            expect(element).to receive(:has_value_for?).with(:headline)
            subject.has?(:headline)
          end
        end
      end

      describe "#ingredient_by_role" do
        let(:element) { create(:alchemy_element, :with_ingredients) }
        let(:ingredient) { element.ingredient_by_role(:headline) }

        it "returns the ingredient record by role" do
          expect(subject.ingredient_by_role(:headline)).to eq(ingredient)
        end
      end
    end
  end
end
