# frozen_string_literal: true

require "rails_helper"

# These specs verify that after PicturePreloader has run, rendering
# Alchemy::Ingredients::PictureView makes no additional database queries.
#
# Uses a real, unstubbbed ingredient connected to a real element/page/language
# so that alt_text resolves its language through the association chain rather
# than falling back to Alchemy::Current.language (which is reset by the
# Rails executor around every ActiveSupport::Notifications subscription).
RSpec.describe Alchemy::IngredientPreloaders::PicturePreloader, type: :component do
  include ViewComponent::TestHelpers

  let!(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat") }
  let!(:picture) { create(:alchemy_picture) }

  let(:ingredient) do
    ing = element.ingredients.find { |i| i.role == "picture" }
    ing.update!(related_object: picture)
    ing
  end

  before do
    Alchemy::Current.language = element.page.language
    ingredient # ensure ingredient + related_object are persisted
    # Pre-render once so Dragonfly creates the thumb record for this size/signature.
    # The INSERT only happens on first render; subsequent renders find the thumb
    # in the preloaded :thumbs association without touching the DB.
    render_inline Alchemy::Ingredients::PictureView.new(ingredient)
    described_class.call([picture.reload])
  end

  it "renders PictureView without making database queries" do
    expect {
      render_inline Alchemy::Ingredients::PictureView.new(ingredient)
    }.not_to make_database_queries
  end
end
