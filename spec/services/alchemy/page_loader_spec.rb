# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PageLoader do
  let(:page) { create(:alchemy_page, :public) }
  let(:page_version) { page.public_version }

  describe ".call" do
    it "raises on an unrecognised version symbol" do
      expect {
        described_class.call(page: page, version: :nonsense_version)
      }.to raise_error(Alchemy::UnsupportedPageVersion)
    end

    it "is a no-op when the requested version does not exist" do
      page_without_public_version = create(:alchemy_page)
      expect {
        described_class.call(page: page_without_public_version, version: :public_version)
      }.not_to raise_error
    end

    it "accepts :draft_version" do
      expect {
        described_class.call(page: page, version: :draft_version)
      }.not_to raise_error
    end
  end

  describe "#call (via .call)" do
    subject(:loader) { described_class.call(page: page, version: :public_version) }

    context "with no elements" do
      it "returns nil" do
        expect(loader).to be_nil
      end

      it "does not raise" do
        expect { loader }.not_to raise_error
      end
    end

    context "with flat elements (no nesting)" do
      let!(:element1) { create(:alchemy_element, page_version: page_version, position: 1) }
      let!(:element2) { create(:alchemy_element, page_version: page_version, position: 2) }

      before { loader }

      it "populates all_nested_elements on each element" do
        expect(page_version.element_repository.to_a.first.association(:all_nested_elements)).to be_loaded
      end

      it "seeds element_repository so it is served from memory" do
        count = 0
        sub = ActiveSupport::Notifications.subscribe("sql.active_record") { |*, payload|
          count += 1 if /alchemy_elements/i.match?(payload[:sql])
        }
        page_version.element_repository.to_a
        ActiveSupport::Notifications.unsubscribe(sub)

        expect(count).to eq(0)
      end

      it "populates page.elements in-memory" do
        count = 0
        sub = ActiveSupport::Notifications.subscribe("sql.active_record") { |*, payload|
          count += 1 if /alchemy_elements/i.match?(payload[:sql])
        }
        page.elements.to_a
        ActiveSupport::Notifications.unsubscribe(sub)

        expect(count).to eq(0)
      end

      it "populates page.all_elements in-memory" do
        count = 0
        sub = ActiveSupport::Notifications.subscribe("sql.active_record") { |*, payload|
          count += 1 if /alchemy_elements/i.match?(payload[:sql])
        }
        page.all_elements.to_a
        ActiveSupport::Notifications.unsubscribe(sub)

        expect(count).to eq(0)
      end
    end

    context "with nested elements (2 levels)" do
      let!(:slider) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slide1) { create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider, position: 1) }
      let!(:slide2) { create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider, position: 2) }

      before { loader }

      it "populates all_nested_elements on the parent element" do
        root = page_version.element_repository.to_a.find { |e| e.id == slider.id }
        expect(root.association(:all_nested_elements)).to be_loaded
        expect(root.all_nested_elements).to contain_exactly(slide1, slide2)
      end

      it "preserves position order in nested elements" do
        root = page_version.element_repository.to_a.find { |e| e.id == slider.id }
        expect(root.all_nested_elements).to eq([slide1, slide2])
      end

      it "preloads ingredients on nested elements" do
        root = page_version.element_repository.to_a.find { |e| e.id == slider.id }
        nested = root.all_nested_elements.first
        expect(nested.association(:ingredients)).to be_loaded
      end
    end

    context "with deeply nested elements (3 levels)" do
      let!(:slider) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slide) { create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider) }
      let!(:deeply_nested) { create(:alchemy_element, name: "article", page_version: page_version, parent_element: slide) }

      before { loader }

      it "preloads all three levels" do
        root = page_version.element_repository.to_a.find { |e| e.id == slider.id }
        expect(root.association(:all_nested_elements)).to be_loaded

        level2 = root.all_nested_elements.find { |e| e.id == slide.id }
        expect(level2.association(:all_nested_elements)).to be_loaded

        level3 = level2.all_nested_elements.find { |e| e.id == deeply_nested.id }
        expect(level3.association(:all_nested_elements)).to be_loaded
      end
    end

    context "with ingredients and related objects" do
      let!(:picture) { create(:alchemy_picture) }
      let!(:element) do
        create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page_version)
      end

      before do
        picture_ingredient = element.ingredients.find { |i| i.role == "picture" }
        picture_ingredient&.update!(related_object: picture)
      end

      before { loader }

      it "preloads ingredients on elements" do
        el = page_version.element_repository.to_a.find { |e| e.id == element.id }
        expect(el.association(:ingredients)).to be_loaded
      end

      it "preloads related_object on ingredients" do
        el = page_version.element_repository.to_a.find { |e| e.id == element.id }
        ingredient = el.ingredients.find { |i| i.role == "picture" }
        expect(ingredient.association(:related_object)).to be_loaded
      end
    end

    context "with nil positions in nested elements" do
      let!(:parent_element) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:nested_element) do
        create(:alchemy_element, page_version: page_version, parent_element: parent_element).tap do |e|
          e.update_column(:position, nil)
        end
      end
      let!(:other_nested_element) { create(:alchemy_element, page_version: page_version, parent_element: parent_element, position: 1) }

      it "does not raise and includes all nested elements" do
        loader
        root = page_version.element_repository.to_a.find { |e| e.id == parent_element.id }
        expect(root.all_nested_elements).to match_array([nested_element, other_nested_element])
      end
    end

    context "query efficiency" do
      let!(:slider1) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slider2) { create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false) }
      let!(:slides1) { Array.new(3) { |i| create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider1, position: i) } }
      let!(:slides2) { Array.new(3) { |i| create(:alchemy_element, name: "slide", page_version: page_version, parent_element: slider2, position: i) } }

      it "loads all elements and ingredients in a fixed number of queries regardless of count" do
        expect {
          described_class.call(page: page, version: :public_version)

          page_version.element_repository.to_a.each do |root|
            root.all_nested_elements.each do |nested|
              nested.ingredients.to_a
              nested.all_nested_elements.to_a
            end
          end
        }.to make_database_queries(count: 2)
        # 2 queries: the elements+ingredients+related_objects load issued by
        # PageLoader, plus the page.public_version load triggered by .call
        # when public_version is not yet cached on the page object.
      end
    end
  end

  describe "alchemy_ingredient_preloads hook (hook 1: ingredient class)" do
    let!(:picture) { create(:alchemy_picture) }
    let!(:element) do
      create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page_version)
    end

    before do
      picture_ingredient = element.ingredients.find { |i| i.role == "picture" }
      picture_ingredient&.update!(related_object: picture)
    end

    it "calls alchemy_ingredient_preloads on the ingredient class" do
      expect(Alchemy::Ingredients::Picture).to receive(:alchemy_ingredient_preloads)
        .with(array_including(an_instance_of(Alchemy::Ingredients::Picture)))

      described_class.call(page: page, version: :public_version)
    end

    it "calls alchemy_ingredient_preloads for ingredient types in nested elements" do
      slider = create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false)
      slide = create(:alchemy_element, :with_ingredients, name: "slide", page_version: page_version, parent_element: slider)
      slide_picture = slide.ingredients.find { |i| i.respond_to?(:picture) }
      slide_picture&.update!(related_object: picture)

      expect(Alchemy::Ingredients::Picture).to receive(:alchemy_ingredient_preloads)

      described_class.call(page: page, version: :public_version)
    end
  end

  describe "alchemy_element_preloads hook (hook 2: related_object class)" do
    let!(:picture) { create(:alchemy_picture) }
    let!(:element) do
      create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page_version)
    end

    before do
      picture_ingredient = element.ingredients.find { |i| i.role == "picture" }
      picture_ingredient&.update!(related_object: picture)
    end

    it "calls alchemy_element_preloads on the related_object class" do
      expect(Alchemy::Picture).to receive(:alchemy_element_preloads).with(array_including(picture))

      described_class.call(page: page, version: :public_version)
    end

    it "calls alchemy_element_preloads with related_objects from nested elements" do
      slider = create(:alchemy_element, :with_nestable_elements, page_version: page_version, autogenerate_nested_elements: false)
      slide = create(:alchemy_element, :with_ingredients, name: "slide", page_version: page_version, parent_element: slider)
      slide_picture = slide.ingredients.find { |i| i.respond_to?(:picture) }
      slide_picture&.update!(related_object: picture)

      expect(Alchemy::Picture).to receive(:alchemy_element_preloads).with(array_including(picture))

      described_class.call(page: page, version: :public_version)
    end
  end

  describe "Picture thumbnail preloading (integration)", if: Alchemy.storage_adapter.dragonfly? do
    let!(:picture) { create(:alchemy_picture) }
    let!(:element) do
      create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page_version)
    end

    before do
      picture_ingredient = element.ingredients.find { |i| i.role == "picture" }
      picture_ingredient&.update!(related_object: picture)
    end

    it "preloads thumbnails so they are served from memory" do
      described_class.call(page: page, version: :public_version)

      el = page_version.element_repository.to_a.find { |e| e.id == element.id }
      loaded_picture = el.ingredients.find { |i| i.role == "picture" }.related_object

      count = 0
      sub = ActiveSupport::Notifications.subscribe("sql.active_record") { |*, payload|
        count += 1 if payload[:sql].include?("alchemy_picture_thumbs")
      }
      loaded_picture.thumbs.to_a
      ActiveSupport::Notifications.unsubscribe(sub)

      expect(count).to eq(0)
    end
  end
end
