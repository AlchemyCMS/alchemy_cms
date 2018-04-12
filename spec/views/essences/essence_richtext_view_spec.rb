# frozen_string_literal: true

require 'spec_helper'

describe 'alchemy/essences/_essence_richtext_view' do
  let(:essence) { Alchemy::EssenceRichtext.new(body: '<h1>Lorem ipsum dolor sit amet</h1> <p>consectetur adipiscing elit.</p>', stripped_body: 'Lorem ipsum dolor sit amet consectetur adipiscing elit.') }
  let(:content) { Alchemy::Content.new(essence: essence) }

  it "renders the html body" do
    render content, content: content
    expect(rendered).to have_content('Lorem ipsum dolor sit amet consectetur adipiscing elit.')
    expect(rendered).to have_selector('h1')
  end

  context 'with options[:plain_text] true' do
    it "renders the text body" do
      render content, content: content, options: {plain_text: true}
      expect(rendered).to have_content('Lorem ipsum dolor sit amet consectetur adipiscing elit.')
      expect(rendered).to_not have_selector('h1')
    end
  end

  context 'with content.settings[:plain_text] true' do
    before do
      allow(content).to receive(:settings).and_return({plain_text: true})
    end

    it "renders the text body" do
      render content.essence, content: content
      expect(rendered).to have_content('Lorem ipsum dolor sit amet consectetur adipiscing elit.')
      expect(rendered).to_not have_selector('h1')
    end
  end
end
