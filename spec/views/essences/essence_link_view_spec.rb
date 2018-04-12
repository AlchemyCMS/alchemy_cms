# frozen_string_literal: true

require 'spec_helper'

describe 'alchemy/essences/_essence_link_view' do
  let(:essence) { Alchemy::EssenceLink.new(link: 'http://google.com') }
  let(:content) { Alchemy::Content.new(essence: essence) }
  let(:options) { {} }

  context 'without value' do
    let(:essence) { Alchemy::EssenceLink.new(link: nil) }

    it "renders nothing" do
      render content, content: content, options: options, html_options: {}
      expect(rendered).to eq('')
    end
  end

  it "renders a link" do
    render content, content: content, options: options, html_options: {}
    expect(rendered).to eq('<a href="http://google.com">http://google.com</a>')
  end

  context 'with text option' do
    let(:options) { {text: 'Google'} }

    it "renders a link" do
      render content, content: content, options: options, html_options: {}
      expect(rendered).to eq('<a href="http://google.com">Google</a>')
    end
  end

  context 'with text setting on content definition' do
    before do
      allow(content).to receive(:settings).and_return({text: 'Yahoo'})
    end

    it "renders a link" do
      render content.essence, content: content, options: options, html_options: {}
      expect(rendered).to eq('<a href="http://google.com">Yahoo</a>')
    end
  end
end
