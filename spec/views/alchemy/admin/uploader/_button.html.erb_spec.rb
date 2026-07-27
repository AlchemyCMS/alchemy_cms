# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/admin/uploader/_button.html.erb" do
  let(:object) { Alchemy::Picture.new }
  let(:file_attribute) { :image_file }
  let(:redirect_url) { "/admin/pictures" }
  let(:component) { instance_double(Alchemy::Admin::UploaderButton, render_in: "") }

  subject(:render_partial) do
    render partial: "alchemy/admin/uploader/button",
      locals: {object:, file_attribute:, redirect_url:}
  end

  before do
    allow(Alchemy::Deprecation).to receive(:warn)
    allow(Alchemy::Admin::UploaderButton).to receive(:new).and_return(component)
  end

  it "renders the UploaderButton component with the forwarded arguments" do
    expect(Alchemy::Admin::UploaderButton).to receive(:new).with(
      object:,
      file_attribute:,
      redirect_url:,
      accept: nil,
      dropzone: nil,
      label: nil
    ).and_return(component)
    render_partial
  end

  it "warns about the deprecation" do
    expect(Alchemy::Deprecation).to receive(:warn)
    render_partial
  end
end
