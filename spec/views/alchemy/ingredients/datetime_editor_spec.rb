# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_datetime_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }
  let(:ingredient) { Alchemy::Ingredients::Datetime.build(role: "datetime", element: element) }

  before do
    allow(element_editor).to receive(:ingredients) { [Alchemy::IngredientEditor.new(ingredient)] }
    view.class.send(:include, Alchemy::Admin::BaseHelper)
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a datepicker" do
    render element_editor
    expect(rendered).to have_css('input[type="text"][data-datepicker-type="date"].date')
  end
end
