# frozen_string_literal: true

require "rails_helper"

describe "alchemy/admin/attachments/_replace_button.html.erb" do
  let(:object) { Alchemy::Attachment.new }
  let(:file_attribute) { :file }
  let(:redirect_url) { "/admin/attachments" }

  before do
    allow(view).to receive(:admin_attachments_path).and_return("/admin/attachments")
    view.extend Alchemy::BaseHelper
  end

  it "renders a alchemy-uploader component" do
    render partial: "alchemy/admin/attachments/replace_button",
      locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}
    expect(rendered).to have_selector("alchemy-uploader[redirect-url='/admin/attachments']")
  end
end
