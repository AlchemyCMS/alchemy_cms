# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/essences/_essence_page_editor" do
  let(:content) { Alchemy::Content.new(essence: essence) }
  let(:essence) { Alchemy::EssencePage.new }

  before do
    view.class.send(:include, Alchemy::Admin::EssencesHelper)
    allow(view).to receive(:content_label).and_return(content.name)
  end

  subject do
    render "alchemy/essences/essence_page_editor", essence_page_editor: Alchemy::ContentEditor.new(content)
    rendered
  end

  it "renders a page input" do
    is_expected.to have_css("input.alchemy_selectbox.full_width")
  end

  context "with a page related to essence" do
    let(:page) { Alchemy::Page.new(id: 1) }
    let(:essence) { Alchemy::EssencePage.new(page_id: page.id) }

    it "sets page id as value" do
      is_expected.to have_css('input.alchemy_selectbox[value="1"]')
    end
  end
end
