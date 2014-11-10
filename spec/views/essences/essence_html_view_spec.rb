require 'spec_helper'

describe 'alchemy/essences/_essence_html_view' do
  let(:essence) { Alchemy::EssenceHtml.new(source: '<script>alert("hacked");</script>') }
  let(:content) { Alchemy::Content.new(essence: essence) }

  context 'without value' do
    let(:essence) { Alchemy::EssenceHtml.new(source: nil) }

    it "renders nothing" do
      render content, content: content
      expect(rendered).to eq('')
    end
  end

  context 'with value' do
    it "renders the raw html source" do
      render content, content: content
      expect(rendered).to have_selector("script")
    end
  end
end
