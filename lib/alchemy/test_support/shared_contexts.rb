RSpec.shared_context 'with invalid file' do
  let(:invalid_file) do
    fixture_file_upload(
      File.expand_path('../../../spec/fixtures/users.yml', __dir__),
      'text/x-yaml'
    )
  end

  before do
    allow(Alchemy::Attachment).to receive(:allowed_filetypes) do
      ['png']
    end
  end
end
