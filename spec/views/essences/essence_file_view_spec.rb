require 'spec_helper'

describe 'alchemy/essences/_essence_file_view' do
  let(:file)       { File.new(File.expand_path('../../../fixtures/image with spaces.png', __FILE__)) }
  let(:attachment) { mock_model('Attachment', file: file, name: 'image', file_name: 'Image') }
  let(:essence)    { Alchemy::EssenceFile.new(attachment: attachment) }
  let(:content)    { Alchemy::Content.new(essence: essence) }

  context 'without attachment' do
    let(:essence) { Alchemy::EssenceFile.new(attachment: nil) }

    it "renders nothing" do
      render content, content: content
      expect(rendered).to eq('')
    end
  end

  context 'with attachment' do
    it "renders a link to download the attachment" do
      render content, content: content
      expect(rendered).to have_selector("a.file_link[href='/attachment/#{attachment.id}/download']")
    end
  end
end
