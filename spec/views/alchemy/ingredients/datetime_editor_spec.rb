# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_datetime_editor" do
  let(:element) { Alchemy::Element.new(name: "all_you_can_eat_ingredients") }
  let(:ingredient) { Alchemy::Ingredients::Datetime.build(role: "datetime", element: element) }

  before do
    view.class.send(:include, Alchemy::Admin::BaseHelper)
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
  end

  it "renders a datepicker" do
    render "alchemy/ingredients/datetime_editor",
      datetime_editor: Alchemy::IngredientEditor.new(ingredient),
      datetime_editor_counter: 0
    expect(rendered).to have_css('input[type="text"][data-datepicker-type="date"].date')
  end
end
