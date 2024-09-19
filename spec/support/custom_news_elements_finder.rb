# frozen_string_literal: true

class CustomNewsElementsFinder
  def elements(*)
    [element]
  end

  private

  def element
    Alchemy::Element.new(
      name: "news",
      id: 1001,
      position: 1
    ).tap do |element|
      element.ingredients = ingredients(element)
    end
  end

  def ingredients(element)
    [
      Alchemy::Ingredients::Text.new(
        element: element,
        role: "news_headline",
        value: "Breaking News"
      ),
      Alchemy::Ingredients::Richtext.new(
        element: element,
        role: "body",
        value: "<p>This is a breaking news story.</p>"
      )
    ]
  end
end
