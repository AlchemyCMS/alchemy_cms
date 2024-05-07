# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LegacyPageUrlsController do
  routes { Alchemy::Engine.routes }

  before do
    authorize_user(:as_admin)
  end

  describe "#update" do
    subject do
      patch :update, params: {id: page_url.id, page_id: page.id, legacy_page_url: {urlname: ""}}
    end

    let(:page) { create(:alchemy_page) }
    let(:page_url) { Alchemy::LegacyPageUrl.create!(page: page, urlname: "foo") }

    context "with failing validations" do
      it "re-renders edit form" do
        expect(subject.status).to eq 422
        is_expected.to render_template(:edit)
      end
    end
  end
end
