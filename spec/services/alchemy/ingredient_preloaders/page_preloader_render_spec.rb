# frozen_string_literal: true

require "rails_helper"

# These specs verify that after PagePreloader has run, rendering
# Alchemy::Ingredients::PageView makes no additional database queries.
RSpec.describe Alchemy::IngredientPreloaders::PagePreloader, type: :component do
  include ViewComponent::TestHelpers

  let!(:alchemy_page) { create(:alchemy_page) }

  # Reload to clear any associations that were eagerly loaded during creation
  let(:reloaded_page) { Alchemy::Page.find(alchemy_page.id) }

  let(:ingredient) do
    Alchemy::Ingredients::Page.new(page: reloaded_page)
  end

  before do
    described_class.call([reloaded_page])
  end

  it "renders PageView without making database queries" do
    expect {
      render_inline Alchemy::Ingredients::PageView.new(ingredient)
    }.not_to make_database_queries
  end
end
