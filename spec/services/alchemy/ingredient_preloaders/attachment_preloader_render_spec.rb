# frozen_string_literal: true

require "rails_helper"

# These specs verify that after AttachmentPreloader has run, rendering
# Alchemy::Ingredients::{File,Audio,Video}View makes no additional database queries.
RSpec.describe Alchemy::IngredientPreloaders::AttachmentPreloader, type: :component do
  include ViewComponent::TestHelpers

  let!(:attachment) { create(:alchemy_attachment) }

  # Reload to clear any associations that were eagerly loaded during creation
  let(:reloaded_attachment) { Alchemy::Attachment.find(attachment.id) }

  before do
    described_class.call([reloaded_attachment])
  end

  describe "FileView" do
    let(:ingredient) do
      Alchemy::Ingredients::File.new(attachment: reloaded_attachment)
    end

    it "renders without making database queries" do
      expect {
        render_inline Alchemy::Ingredients::FileView.new(ingredient)
      }.not_to make_database_queries
    end
  end

  describe "AudioView" do
    let(:ingredient) do
      Alchemy::Ingredients::Audio.new(
        role: "audio",
        attachment: reloaded_attachment,
        controls: true
      )
    end

    it "renders without making database queries" do
      expect {
        render_inline Alchemy::Ingredients::AudioView.new(ingredient)
      }.not_to make_database_queries
    end
  end

  describe "VideoView" do
    let(:ingredient) do
      Alchemy::Ingredients::Video.new(
        role: "video",
        attachment: reloaded_attachment,
        controls: true
      )
    end

    it "renders without making database queries" do
      expect {
        render_inline Alchemy::Ingredients::VideoView.new(ingredient)
      }.not_to make_database_queries
    end
  end
end
