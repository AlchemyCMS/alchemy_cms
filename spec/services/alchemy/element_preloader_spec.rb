# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementPreloader do
  let(:page_version) { create(:alchemy_page_version) }

  describe "#call" do
    context "with no elements" do
      it "returns empty array" do
        preloader = described_class.new(elements: Alchemy::Element.none)
        expect(preloader.call).to eq([])
      end
    end

    context "with flat elements (no nesting)" do
      let!(:element1) { create(:alchemy_element, page_version: page_version, position: 1) }
      let!(:element2) { create(:alchemy_element, page_version: page_version, position: 2) }

      subject do
        elements = page_version.elements.not_nested.order(:position)
        described_class.new(elements: elements).call
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
        elements = page_version.elements.not_nested.order(:position)
        described_class.new(elements: elements).call
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

      it "orders unfixed elements before fixed elements, each by position" do
        # Position is scoped by [page_version_id, fixed, parent_element_id]
        # Create fixed elements with their own position sequence
        fixed1 = create(:alchemy_element, :fixed, name: "slide", page_version: page_version, parent_element: slider, position: 1)
        fixed2 = create(:alchemy_element, :fixed, name: "slide", page_version: page_version, parent_element: slider, position: 2)

        elements = page_version.elements.not_nested.order(:position)
        result = described_class.new(elements: elements).call

        # Unfixed elements (slide1, slide2) should come before fixed elements (fixed1, fixed2)
        expect(result.first.all_nested_elements).to eq([slide1, slide2, fixed1, fixed2])
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
        elements = page_version.elements.not_nested.order(:position)
        described_class.new(elements: elements).call
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
        elements = page_version.elements.not_nested.order(:position)
        described_class.new(elements: elements).call
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

      it "preloads both fixed and unfixed elements when given all" do
        elements = page_version.elements.not_nested.order(:position)
        result = described_class.new(elements: elements).call

        expect(result).to contain_exactly(regular_element, fixed_element)
        result.each do |elem|
          expect(elem.association(:all_nested_elements)).to be_loaded
        end
      end

      it "preloads only unfixed elements when filtered" do
        elements = page_version.elements.not_nested.unfixed.order(:position)
        result = described_class.new(elements: elements).call

        expect(result).to eq([regular_element])
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
        elements = page_version.elements.not_nested.order(:position)

        # Queries are bounded regardless of element count (8 elements created)
        # Root elements, all elements, ingredients, related objects, tags
        # No language passed, so no description/thumb preloading
        expect {
          result = described_class.new(elements: elements).call

          # Access all nested elements to ensure they're loaded
          result.each do |root|
            root.all_nested_elements.each do |nested|
              nested.ingredients.to_a
              nested.all_nested_elements.to_a
            end
          end
        }.to make_database_queries(count: 7)
      end
    end
  end

  describe "related object preloading" do
    let(:language) { page_version.page.language }

    context "without language parameter" do
      let!(:picture) { create(:alchemy_picture) }
      let!(:element) do
        create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page_version)
      end

      before do
        picture_ingredient = element.ingredients.find { |i| i.role == "picture" }
        picture_ingredient&.update!(related_object: picture)
      end

      it "does not preload related objects" do
        elements = page_version.elements.not_nested.order(:position)
        preloaded = described_class.new(elements: elements).call

        picture_ingredient = preloaded.first.ingredients.find { |i| i.role == "picture" }
        loaded_picture = picture_ingredient.related_object

        expect(loaded_picture.instance_variable_defined?(:@preloaded_description)).to be false
      end
    end

    context "with language parameter" do
      let!(:picture) { create(:alchemy_picture) }
      let!(:element) do
        create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page_version)
      end
      let!(:description) do
        Alchemy::PictureDescription.create!(picture: picture, language: language, text: "Test description")
      end

      before do
        picture_ingredient = element.ingredients.find { |i| i.role == "picture" }
        picture_ingredient&.update!(related_object: picture)
      end

      it "calls alchemy_element_preloads on Picture class" do
        elements = page_version.elements.not_nested.order(:position)

        expect(Alchemy::Picture).to receive(:alchemy_element_preloads).with(
          array_including(picture),
          language: language
        )

        described_class.new(elements: elements, language: language).call
      end

      it "preloads picture descriptions" do
        elements = page_version.elements.not_nested.order(:position)
        preloaded = described_class.new(elements: elements, language: language).call

        picture_ingredient = preloaded.first.ingredients.find { |i| i.role == "picture" }
        loaded_picture = picture_ingredient.related_object

        expect(loaded_picture.instance_variable_defined?(:@preloaded_description)).to be true
        expect(loaded_picture.description_for(language)).to eq("Test description")
      end

      it "avoids N+1 queries for picture descriptions" do
        # Create multiple pictures with descriptions
        pictures = Array.new(3) { create(:alchemy_picture) }
        pictures.each do |pic|
          Alchemy::PictureDescription.create!(picture: pic, language: language, text: "Desc for #{pic.id}")
        end

        # Create multiple elements with picture ingredients
        pictures.each do |pic|
          el = create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page_version)
          picture_ingredient = el.ingredients.find { |i| i.role == "picture" }
          picture_ingredient&.update!(related_object: pic)
        end

        elements = page_version.elements.not_nested.order(:position)

        # Expected queries:
        # Root elements, all elements, ingredients, related objects, tags,
        # picture descriptions, picture storage associations (thumbs for Dragonfly, attachment+blob for ActiveStorage)
        # No additional queries when accessing descriptions (preloaded)
        expected_queries = Alchemy.storage_adapter.dragonfly? ? 11 : 12

        expect {
          preloaded = described_class.new(elements: elements, language: language).call

          # Access all picture descriptions
          preloaded.each do |el|
            el.ingredients.each do |ing|
              if ing.respond_to?(:picture) && ing.picture
                ing.picture.description_for(language)
              end
            end
          end
        }.to make_database_queries(count: expected_queries)
      end
    end

    context "with nested elements containing pictures" do
      let!(:picture) { create(:alchemy_picture) }
      let!(:slider) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slide) do
        create(:alchemy_element, :with_ingredients, name: "slide", page_version: page_version, parent_element: slider)
      end
      let!(:description) do
        Alchemy::PictureDescription.create!(picture: picture, language: language, text: "Nested description")
      end

      before do
        picture_ingredient = slide.ingredients.find { |i| i.respond_to?(:picture) }
        picture_ingredient&.update!(related_object: picture)
      end

      it "preloads pictures from nested elements" do
        elements = page_version.elements.not_nested.order(:position)
        preloaded = described_class.new(elements: elements, language: language).call

        nested_element = preloaded.first.all_nested_elements.first
        picture_ingredient = nested_element.ingredients.find { |i| i.respond_to?(:picture) }

        next unless picture_ingredient&.related_object

        loaded_picture = picture_ingredient.related_object
        expect(loaded_picture.instance_variable_defined?(:@preloaded_description)).to be true
      end
    end
  end
end
