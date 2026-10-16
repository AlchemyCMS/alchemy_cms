# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementsPreloader do
  let(:picture_preloader)    { class_double("Alchemy::IngredientPreloaders::PicturePreloader") }
  let(:attachment_preloader) { class_double("Alchemy::IngredientPreloaders::AttachmentPreloader") }

  before do
    stub_const("Alchemy::IngredientPreloaders::PicturePreloader", picture_preloader)
    stub_const("Alchemy::IngredientPreloaders::AttachmentPreloader", attachment_preloader)

    allow(Alchemy.config.ingredient_preloaders).to receive(:[]) do |key|
      {
        "Alchemy::Ingredients::Picture" => picture_preloader,
        "Alchemy::Ingredients::File"    => attachment_preloader,
        "Alchemy::Ingredients::Audio"   => attachment_preloader
      }[key]
    end
  end

  # Builds a minimal ingredient double with a given class name and related object.
  def stub_ingredient(ingredient_class, related_object)
    instance_double(Alchemy::Ingredient,
      class: ingredient_class,
      related_object: related_object)
  end

  # Builds a minimal element double with the given ingredients.
  def stub_element(*ingredients)
    instance_double(Alchemy::Element, ingredients: ingredients)
  end

  # Builds a minimal related-object double with an id.
  def stub_related(id)
    double("related_#{id}", id: id)
  end

  describe ".call" do
    it "delegates to a new instance" do
      elements = []
      instance = instance_double(described_class, call: nil)
      allow(described_class).to receive(:new).with(elements).and_return(instance)
      described_class.call(elements)
      expect(instance).to have_received(:call)
    end
  end

  describe "#call" do
    context "with an empty element collection" do
      it "calls no preloaders" do
        expect(picture_preloader).not_to receive(:call)
        expect(attachment_preloader).not_to receive(:call)
        described_class.new([]).call
      end
    end

    context "with elements whose ingredients have no related objects" do
      let(:element) do
        stub_element(
          stub_ingredient(Alchemy::Ingredients::Text, nil)
        )
      end

      it "calls no preloaders" do
        expect(picture_preloader).not_to receive(:call)
        described_class.new([element]).call
      end
    end

    context "with an ingredient type not in the config map" do
      let(:element) do
        stub_element(
          stub_ingredient(Alchemy::Ingredients::Text, stub_related(1))
        )
      end

      it "calls no preloaders" do
        expect(picture_preloader).not_to receive(:call)
        expect(attachment_preloader).not_to receive(:call)
        described_class.new([element]).call
      end
    end

    context "with a single ingredient type across multiple elements" do
      let(:picture1) { stub_related(1) }
      let(:picture2) { stub_related(2) }

      let(:elements) do
        [
          stub_element(stub_ingredient(Alchemy::Ingredients::Picture, picture1)),
          stub_element(stub_ingredient(Alchemy::Ingredients::Picture, picture2))
        ]
      end

      it "calls the matching preloader once with all related objects" do
        expect(picture_preloader).to receive(:call).once.with(contain_exactly(picture1, picture2))
        described_class.new(elements).call
      end
    end

    context "when the same related object appears in multiple elements" do
      let(:picture) { stub_related(1) }

      let(:elements) do
        [
          stub_element(stub_ingredient(Alchemy::Ingredients::Picture, picture)),
          stub_element(stub_ingredient(Alchemy::Ingredients::Picture, picture))
        ]
      end

      it "deduplicates by id and calls the preloader exactly once with one object" do
        expect(picture_preloader).to receive(:call).once.with([picture])
        described_class.new(elements).call
      end
    end

    context "with multiple ingredient types sharing a preloader" do
      let(:file_obj)  { stub_related(10) }
      let(:audio_obj) { stub_related(20) }

      let(:elements) do
        [
          stub_element(stub_ingredient(Alchemy::Ingredients::File,  file_obj)),
          stub_element(stub_ingredient(Alchemy::Ingredients::Audio, audio_obj))
        ]
      end

      it "calls the shared preloader exactly once with the merged objects" do
        expect(attachment_preloader).to receive(:call).once.with(contain_exactly(file_obj, audio_obj))
        described_class.new(elements).call
      end
    end

    context "with multiple ingredient types mapping to different preloaders" do
      let(:picture) { stub_related(1) }
      let(:file_obj) { stub_related(2) }

      let(:elements) do
        [
          stub_element(
            stub_ingredient(Alchemy::Ingredients::Picture, picture),
            stub_ingredient(Alchemy::Ingredients::File,    file_obj)
          )
        ]
      end

      it "calls each preloader independently" do
        expect(picture_preloader).to receive(:call).with([picture])
        expect(attachment_preloader).to receive(:call).with([file_obj])
        described_class.new(elements).call
      end
    end
  end
end
