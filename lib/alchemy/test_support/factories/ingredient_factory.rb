# frozen_string_literal: true

FactoryBot.define do
  %w[
    audio
    boolean
    datetime
    file
    headline
    html
    link
    node
    page
    picture
    richtext
    select
    text
  ].each do |ingredient|
    factory :"alchemy_ingredient_#{ingredient}", class: "Alchemy::Ingredients::#{ingredient.classify}" do
      role { ingredient }
      type { "Alchemy::Ingredients::#{ingredient.classify}" }
      association :element, name: "all_you_can_eat_ingredients", factory: :alchemy_element
    end
  end
end
