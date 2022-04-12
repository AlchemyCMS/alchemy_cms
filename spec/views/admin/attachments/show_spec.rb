# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/admin/attachments/show.html.erb" do
  let(:attachment) do
    create(:alchemy_attachment)
  end

  it "displays urls to file" do
    assign(:attachment, attachment)
    render
    aggregate_failures do
      expect(rendered).to have_selector("label:contains('URL') + p:contains('/attachment/#{attachment.id}/show')")
      expect(rendered).to have_selector("label:contains('Download-URL') + p:contains('/attachment/#{attachment.id}/download')")
      expect(rendered).to have_selector("img[src^='/attachment/#{attachment.id}/show']")
    end
  end
end
