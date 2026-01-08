# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::IngredientEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:ingredient) { Alchemy::Ingredients::Text.new(id: 1, role: "headline", value: "Hello", element: element) }

  let(:element_form) do
    ActionView::Helpers::FormBuilder.new(:element, element, vc_test_view_context, {})
  end

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    allow(ingredient).to receive(:settings) { {} }
    allow(ingredient).to receive(:definition) do
      Alchemy::IngredientDefinition.new(role: "headline", type: "Text")
    end
  end

  describe "#call" do
    context "when ingredient has no editor partial" do
      it "renders the ingredient's editor component" do
        render_inline(described_class.new(ingredient: ingredient))

        expect(page).to have_css(".ingredient-editor.text")
        expect(page).to have_css("input[type='text']")
      end
    end

    context "when ingredient has a deprecated editor partial", :silence_deprecations do
      let(:partial_dir) { Rails.root.join("app/views/alchemy/ingredients") }
      let(:partial_path) { partial_dir.join("_text_editor.html.erb") }

      before do
        # Clear Rails template cache before creating the partial
        ActionView::LookupContext::DetailsKey.clear
        # Create a temporary partial for the test
        FileUtils.mkdir_p(partial_dir)
        File.write(partial_path, "<div class='deprecated-editor'>deprecated</div>")
      end

      after do
        FileUtils.rm_rf(partial_dir)
        # Clear Rails template cache to avoid interference with other tests
        ActionView::LookupContext::DetailsKey.clear
      end

      it "logs a deprecation warning and passes element_form to partial" do
        expect(Alchemy::Deprecation).to receive(:warn).with(/Ingredient editor partials are deprecated!/)

        render_inline(described_class.new(ingredient: ingredient, element_form: element_form))

        expect(page).to have_css(".deprecated-editor")
      end
    end
  end

  describe ".with_collection" do
    let(:ingredients) do
      [
        Alchemy::Ingredients::Text.new(id: 1, role: "headline", element: element),
        Alchemy::Ingredients::Text.new(id: 2, role: "intro", element: element)
      ]
    end

    before do
      ingredients.each do |ing|
        allow(ing).to receive(:settings) { {} }
        allow(ing).to receive(:definition) do
          Alchemy::IngredientDefinition.new(role: ing.role, type: "Text")
        end
      end
    end

    it "renders all ingredients in the collection" do
      render_inline(described_class.with_collection(ingredients))

      expect(page).to have_css(".ingredient-editor", count: 2)
      expect(page).to have_css("[data-ingredient-id='1']")
      expect(page).to have_css("[data-ingredient-id='2']")
    end
  end
end
