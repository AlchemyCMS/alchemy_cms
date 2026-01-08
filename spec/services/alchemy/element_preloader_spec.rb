# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementPreloader do
  let(:page_version) { create(:alchemy_page_version) }

  describe "#call" do
    context "with no elements" do
      it "returns empty array" do
        preloader = described_class.new(page_version: page_version)
        expect(preloader.call).to eq([])
      end
    end

    context "with flat elements (no nesting)" do
      let!(:element1) { create(:alchemy_element, page_version: page_version, position: 1) }
      let!(:element2) { create(:alchemy_element, page_version: page_version, position: 2) }

      subject do
        described_class.new(page_version: page_version).call
      end

      it "returns all root elements" do
        expect(subject).to eq([element1, element2])
      end

      it "preloads all_nested_elements association" do
        expect(subject.first.association(:all_nested_elements)).to be_loaded
      end

      it "preloads ingredients association" do
        expect(subject.first.association(:ingredients)).to be_loaded
      end

      it "preloads tags association" do
        expect(subject.first.association(:tags)).to be_loaded
      end
    end

    context "with nested elements (2 levels)" do
      let!(:slider) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slide1) { create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider, position: 1) }
      let!(:slide2) { create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider, position: 2) }

      subject do
        described_class.new(page_version: page_version).call
      end

      it "returns only root elements" do
        expect(subject).to eq([slider])
      end

      it "preloads nested elements" do
        expect(subject.first.association(:all_nested_elements)).to be_loaded
        expect(subject.first.all_nested_elements).to contain_exactly(slide1, slide2)
      end

      it "preserves position order in nested elements" do
        expect(subject.first.all_nested_elements).to eq([slide1, slide2])
      end

      it "preloads associations on nested elements" do
        nested = subject.first.all_nested_elements.first
        expect(nested.association(:ingredients)).to be_loaded
        expect(nested.association(:tags)).to be_loaded
      end
    end

    context "with deeply nested elements (3 levels)" do
      # We'll use slider with nested elements to simulate depth
      let!(:slider) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slide) { create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider) }

      # Create a nested element inside (model allows it even if config doesn't)
      let!(:deeply_nested) do
        create(:alchemy_element, name: "article", page_version: page_version, parent_element: slide)
      end

      subject do
        described_class.new(page_version: page_version).call
      end

      it "preloads all three levels" do
        root = subject.first
        expect(root.association(:all_nested_elements)).to be_loaded

        level2 = root.all_nested_elements.first
        expect(level2).to eq(slide)
        expect(level2.association(:all_nested_elements)).to be_loaded

        level3 = level2.all_nested_elements.first
        expect(level3).to eq(deeply_nested)
        expect(level3.association(:all_nested_elements)).to be_loaded
      end
    end

    context "with ingredients and related objects" do
      let!(:picture) { create(:alchemy_picture) }
      let!(:element) do
        create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page_version)
      end

      before do
        # Find the picture ingredient and set its related object
        picture_ingredient = element.ingredients.find { |i| i.role == "picture" }
        picture_ingredient&.update!(related_object: picture)
      end

      subject do
        described_class.new(page_version: page_version).call
      end

      it "preloads ingredients" do
        expect(subject.first.association(:ingredients)).to be_loaded
      end

      it "preloads related_object on ingredients" do
        picture_ingredient = subject.first.ingredients.find { |i| i.role == "picture" }
        expect(picture_ingredient.association(:related_object)).to be_loaded
      end
    end

    context "with mixed fixed and unfixed elements" do
      let!(:regular_element) { create(:alchemy_element, page_version: page_version, fixed: false) }
      let!(:fixed_element) { create(:alchemy_element, :fixed, page_version: page_version) }

      it "returns both fixed and unfixed root elements" do
        result = described_class.new(page_version: page_version).call

        expect(result).to contain_exactly(regular_element, fixed_element)
        result.each do |elem|
          expect(elem.association(:all_nested_elements)).to be_loaded
        end
      end
    end

    context "query efficiency" do
      let!(:slider1) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slider2) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slides1) do
        Array.new(3) { |i| create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider1, position: i) }
      end
      let!(:slides2) do
        Array.new(3) { |i| create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider2, position: i) }
      end

      it "loads all nested elements without N+1 queries" do
        # Queries are bounded regardless of element count (8 elements created)
        # language (eager loaded via page), all elements, ingredients, tags
        expect {
          result = described_class.new(page_version: page_version).call

          # Access all nested elements to ensure they're loaded
          result.each do |root|
            root.all_nested_elements.each do |nested|
              nested.ingredients.to_a
              nested.all_nested_elements.to_a
            end
          end
        }.to make_database_queries(count: 4)
      end
    end
  end

  describe "related object preloading" do
    context "with related objects" do
      let!(:picture) { create(:alchemy_picture) }
      let!(:element) do
        create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page_version)
      end

      before do
        picture_ingredient = element.ingredients.find { |i| i.role == "picture" }
        picture_ingredient&.update!(related_object: picture)
      end

      it "calls alchemy_element_preloads on related object classes" do
        expect(Alchemy::Picture).to receive(:alchemy_element_preloads).with(
          array_including(picture)
        )

        described_class.new(page_version: page_version).call
      end
    end

    context "with nested elements containing related objects" do
      let!(:picture) { create(:alchemy_picture) }
      let!(:slider) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slide) do
        create(:alchemy_element, :with_ingredients, name: "slide", page_version: page_version, parent_element: slider)
      end

      before do
        picture_ingredient = slide.ingredients.find { |i| i.respond_to?(:picture) }
        picture_ingredient&.update!(related_object: picture)
      end

      it "calls alchemy_element_preloads with objects from nested elements" do
        expect(Alchemy::Picture).to receive(:alchemy_element_preloads).with(
          array_including(picture)
        )

        described_class.new(page_version: page_version).call
      end
    end
  end
end
