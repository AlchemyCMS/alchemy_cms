# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'alchemy/essences/_essence_page_editor' do
  let(:content) { Alchemy::Content.new(essence: essence) }
  let(:essence) { Alchemy::EssencePage.new }

  before do
    view.class.send(:include, Alchemy::Admin::EssencesHelper)
    allow(view).to receive(:content_label).and_return(content.name)
  end

  it "renders a page select box" do
    render 'alchemy/essences/essence_page_editor', essence_page_editor: Alchemy::ContentEditor.new(content)
    expect(rendered).to have_css('select.alchemy_selectbox.full_width')
  end
end
