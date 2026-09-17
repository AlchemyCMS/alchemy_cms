# frozen_string_literal: true

require "rails_helper"

# These specs verify that after NodePreloader has run, rendering
# Alchemy::Ingredients::NodeView makes no additional database queries.
#
# The node is set up without children so the partial's
# `if node.children.any?` branch (which would call includes) is not entered.
RSpec.describe Alchemy::IngredientPreloaders::NodePreloader, type: :component do
  include ViewComponent::TestHelpers

  let!(:node) { create(:alchemy_node, :with_url) }

  # Reload to clear any associations that were eagerly loaded during creation
  let(:reloaded_node) { Alchemy::Node.find(node.id) }

  let(:ingredient) do
    Alchemy::Ingredients::Node.new(node: reloaded_node)
  end

  before do
    described_class.call([reloaded_node])
  end

  it "renders NodeView without making database queries" do
    expect {
      render_inline Alchemy::Ingredients::NodeView.new(ingredient)
    }.not_to make_database_queries
  end
end
