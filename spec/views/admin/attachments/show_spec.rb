# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/admin/attachments/show.html.erb" do
  let(:attachment) do
    create(:alchemy_attachment)
  end

  it "displays urls to file" do
    assign(:attachment, attachment)
    assign(:assignments, attachment.related_ingredients.joins(element: :page))
    render
    aggregate_failures do
      expect(rendered).to have_selector("label:contains('URL') + p:contains('/attachment/#{attachment.id}/show')")
      expect(rendered).to have_selector("label:contains('Download-URL') + p:contains('/attachment/#{attachment.id}/download')")
      expect(rendered).to have_selector("img[src^='/attachment/#{attachment.id}/show']")
    end
  end

  context "if attachment is used" do
    let!(:file_ingredient) { create(:alchemy_ingredient_file, attachment: attachment) }

    it "links to the page and element outside of the dialog turbo frame" do
      allow(view).to receive(:edit_admin_page_path).and_return("/path")
      assign(:attachment, attachment)
      assign(:assignments, attachment.related_ingredients.joins(element: :page))
      render
      expect(rendered).to have_css(".resource_page_list a[data-turbo-frame='_top']", count: 2)
    end
  end
end
