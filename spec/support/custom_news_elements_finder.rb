# frozen_string_literal: true

class CustomNewsElementsFinder
  def elements(*)
    [Alchemy::Element.new(name: "news", id: 1001, position: 1)]
  end
end
