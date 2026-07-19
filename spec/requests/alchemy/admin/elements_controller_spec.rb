# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ElementsController do
  before do
    authorize_user(:as_admin)
  end

  describe "#collapse" do
    context "collapse element with ingredients" do
      let(:element) { create(:alchemy_element, :with_ingredients, folded: true) }

      context "with validations" do
        let(:element) { create(:alchemy_element, :with_ingredients, name: :all_you_can_eat) }

        it "saves without running validations" do
          post collapse_admin_element_path(id: element.id, format: :js)
          expect(element.reload).to be_folded
        end
      end
    end
  end

  describe "#publish" do
    let(:element) { create(:alchemy_element, public: false) }

    context "with turbo_stream request" do
      subject!(:publish) { patch publish_admin_element_path(id: element.id, format: :turbo_stream) }

      it "publishes element" do
        expect(element.reload).to be_public
      end

      it "replaces element editor via turbo stream" do
        expect(response.body).to include(%(<turbo-stream action="replace" target="element_#{element.id}">))
      end

      context "with validations" do
        let(:element) { create(:alchemy_element, :with_ingredients, name: :all_you_can_eat, public: false) }

        it "saves without running validations" do
          expect(element.reload).to be_public
        end
      end
    end

    context "scheduling with timezone" do
      let(:element) { create(:alchemy_element) }

      it "converts datetime-local values from user timezone to UTC" do
        patch publish_admin_element_path(id: element.id, format: :turbo_stream),
          params: {admin_timezone: "Hawaii", element: {public_on: "2026-06-15T10:00"}}

        expect(response).to have_http_status(:ok)
        # Hawaii is UTC-10, so 10:00 HST should be stored as 20:00 UTC
        expect(element.reload.public_on).to eq(Time.utc(2026, 6, 15, 20, 0))
      end
    end
  end

  describe "#update" do
    let(:element) { create(:alchemy_element) }

    context "if validation failed" do
      before do
        allow_any_instance_of(Alchemy::Element).to receive(:update).and_return(false)
      end

      it "returns 422 status" do
        patch admin_element_path(id: element.id, format: :turbo_stream)
        expect(response.status).to eq 422
      end

      it "responds with a warning growl turbo stream" do
        patch admin_element_path(id: element.id, format: :turbo_stream)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include("<alchemy-growl type=\"warn\">")
      end
    end

    context "if validation succeeded" do
      it "replaces the publish page button reflecting the publishing state" do
        patch admin_element_path(id: element.id, format: :turbo_stream)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include("publish_page_button")
        expect(response.body).to include(Alchemy.t(:explain_publishing))
      end

      context "with a nested element" do
        let(:parent) { create(:alchemy_element, name: "slider") }
        let(:element) { create(:alchemy_element, name: "slide", parent_element: parent) }

        it "replaces the preview text quote of the element and its parent" do
          patch admin_element_path(id: element.id, format: :turbo_stream)
          expect(response.body).to include("element_#{element.id}_preview_text_quote")
          expect(response.body).to include("element_#{parent.id}_preview_text_quote")
        end
      end
    end
  end
end
