# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::PagesController do
    routes { Alchemy::Engine.routes }

    let(:alchemy_page)         { create(:alchemy_page) }
    let!(:current_language)    { create(:alchemy_language, default: true) }

    before { authorize_user(:as_admin) }

    describe "#new" do
      it "Calls PageLayout.layout_for_select with correct params" do
        expect(PageLayout).to receive(:layouts_for_select).with(alchemy_page.parent.id, false, "standard")
        get :new, params: {layout_page: false, parent_id: alchemy_page.id}
      end

      it "Calls Page.all_from_clipboard_for_select with correct params" do
        allow(subject).to receive(:get_clipboard).and_return(["dummy1", "dummy2"])

        expect(Page).to receive(:all_from_clipboard_for_select).with(["dummy1", "dummy2"], current_language.id, false, "standard")
        get :new, params: {layout_page: false, parent_id: alchemy_page.id}
      end
    end
  end
end
