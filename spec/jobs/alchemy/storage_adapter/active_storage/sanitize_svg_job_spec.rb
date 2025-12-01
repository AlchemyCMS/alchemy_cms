require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::ActiveStorage::SanitizeSvgJob,
  type: :job,
  if: Alchemy.storage_adapter.active_storage? do
  let(:picture) do
    create(
      :alchemy_picture,
      image_file: Rack::Test::UploadedFile.new(
        Alchemy::Engine.root.join("spec/fixtures/files/bad.svg"),
        "image/svg+xml"
      )
    )
  end

  it "sanitizes the SVG content by removing dangerous elements and attributes" do
    described_class.new.perform(picture, file_accessor: :image_file)
    sanitized_content = picture.image_file.download

    # Keeps safe SVG structure
    expect(sanitized_content).to include("<svg")
    expect(sanitized_content).to include("<rect")
    expect(sanitized_content).to include("<circle")

    # Removes script elements
    expect(sanitized_content).not_to include("<script>")

    # Removes event handlers
    expect(sanitized_content).not_to include("onload=")
    expect(sanitized_content).not_to include("onclick=")

    # Removes dangerous elements
    expect(sanitized_content).not_to include("<foreignObject")

    # Removes animations targeting href but keeps safe animations
    expect(sanitized_content).not_to include("<set")
    expect(sanitized_content).not_to include('attributeName="href"')
    expect(sanitized_content).to include('<animate attributeName="opacity"')

    # Removes javascript: URLs from href attributes
    expect(sanitized_content).not_to include("javascript:")

    # Keeps safe elements like <a> and <text>
    expect(sanitized_content).to include("<a")
    expect(sanitized_content).to include("<text")
  end

  it "marks the blob as sanitized" do
    described_class.new.perform(picture, file_accessor: :image_file)

    expect(picture.image_file.blob.metadata[:sanitized]).to be true
  end

  it "does not re-sanitize already sanitized SVGs" do
    picture.image_file.blob.update!(metadata: {sanitized: true})

    expect(picture.image_file.blob).not_to receive(:upload)
    described_class.new.perform(picture, file_accessor: :image_file)
  end

  context "when the SVG is a fragment (no XML declaration)" do
    let(:picture) do
      create(
        :alchemy_picture,
        image_file: Rack::Test::UploadedFile.new(
          Alchemy::Engine.root.join("spec/fixtures/files/bad_fragment.svg"),
          "image/svg+xml"
        )
      )
    end

    it "sanitizes the SVG fragment" do
      described_class.new.perform(picture, file_accessor: :image_file)
      sanitized_content = picture.image_file.download

      expect(sanitized_content).to include("<svg")
      expect(sanitized_content).to include("<rect")
      expect(sanitized_content).not_to include("<script>")
      expect(sanitized_content).not_to include("onclick=")
    end
  end

  context "when the file is not an SVG" do
    let(:picture) { create(:alchemy_picture) }

    it "does not sanitize" do
      expect(picture.image_file.blob).not_to receive(:upload)
      described_class.new.perform(picture, file_accessor: :image_file)
    end
  end
end
