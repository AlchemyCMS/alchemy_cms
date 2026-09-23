# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PreviewTime, type: :controller do
  controller(ActionController::Base) do
    include Alchemy::Admin::PreviewTime

    def index
      render plain: Alchemy::Current.preview_time.iso8601
    end

    private

    def can?(*)
      true
    end
  end

  describe "#set_preview_time" do
    context "with alchemy_preview_time param" do
      it "sets Current.preview_time" do
        preview_time = "2026-06-15T12:00:00Z"
        get :index, params: {alchemy_preview_time: preview_time}
        expect(response.body).to eq(Time.zone.parse(preview_time).iso8601)
      end
    end

    context "with blank alchemy_preview_time param" do
      it "does not set Current.preview_time" do
        get :index, params: {alchemy_preview_time: ""}
        expect(Alchemy::Current.attributes[:preview_time]).to be_nil
      end
    end

    context "without alchemy_preview_time param" do
      it "does not set Current.preview_time" do
        get :index
        expect(Alchemy::Current.attributes[:preview_time]).to be_nil
      end
    end

    context "when user cannot edit content" do
      controller(ActionController::Base) do
        include Alchemy::Admin::PreviewTime

        def index
          render plain: "ok"
        end

        private

        def can?(*)
          false
        end
      end

      it "does not set Current.preview_time" do
        get :index, params: {alchemy_preview_time: "2026-06-15T12:00:00Z"}
        expect(Alchemy::Current.attributes[:preview_time]).to be_nil
      end
    end
  end
end
