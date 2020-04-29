# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/essences/_essence_date_editor" do
  let(:content) { Alchemy::Content.new(essence: essence) }
  let(:essence) { Alchemy::EssenceDate.new }

  before do
    view.class.send(:include, Alchemy::Admin::BaseHelper)
    allow(view).to receive(:content_label).and_return(content.name)
  end

  it "renders a datepicker" do
    render "alchemy/essences/essence_date_editor", essence_date_editor: Alchemy::ContentEditor.new(content)
    expect(rendered).to have_css('input[type="text"][data-datepicker-type="date"].date')
  end
end
