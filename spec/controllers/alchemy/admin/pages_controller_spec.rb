# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PagesController do
  routes { Alchemy::Engine.routes }

  before do
    authorize_user(:as_admin)
  end

  describe "#publish" do
    let(:page) { create(:alchemy_page) }

    it "publishes the page" do
      expect_any_instance_of(Alchemy::Page).to receive(:publish!)
      post :publish, params: { id: page }
    end

    context "with publish targets" do
      class FooTarget < ActiveJob::Base
        def perform(_page)
        end
      end

      around do |example|
        Alchemy.publish_targets << FooTarget
        example.run
        Alchemy.instance_variable_set(:@_publish_targets, nil)
      end

      it "performs each target" do
        expect(FooTarget).to receive(:perform_later).with(page)
        post :publish, params: { id: page }
      end
    end
  end
end
