# frozen_string_literal: true

RSpec.shared_context "with invalid file" do
  let(:invalid_file) do
    fixture_file_upload(
      File.expand_path("../../../spec/fixtures/users.yml", __dir__),
      "text/x-yaml"
    )
  end

  before do
    allow(Alchemy::Attachment).to receive(:allowed_filetypes) do
      ["png"]
    end
  end
end

RSpec.shared_context "in preview mode" do
  around do |example|
    Alchemy::Current.preview_page = page
    example.run
    Alchemy::Current.preview_page = nil
  end
end
