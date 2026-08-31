# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configurations::AdminComponents do
  subject(:admin_components) { described_class.new }

  describe "#element_publish_button" do
    it "defaults to the core publish element button component" do
      expect(admin_components.element_publish_button).to eq(Alchemy::Admin::PublishElementButton)
    end

    it "can be overridden with a custom component class" do
      stub_const("Custom::VisibilityButton", Class.new)
      admin_components.element_publish_button = "Custom::VisibilityButton"
      expect(admin_components.element_publish_button).to eq(Custom::VisibilityButton)
    end
  end

  describe "#page_publication_fields" do
    it "defaults to the core page publication fields component" do
      expect(admin_components.page_publication_fields).to eq(Alchemy::Admin::PagePublicationFields)
    end

    it "can be overridden with a custom component class" do
      stub_const("Custom::PageVisibilityFields", Class.new)
      admin_components.page_publication_fields = "Custom::PageVisibilityFields"
      expect(admin_components.page_publication_fields).to eq(Custom::PageVisibilityFields)
    end
  end

  describe "#element_status_indicators" do
    it "defaults to the core element status indicators component" do
      expect(admin_components.element_status_indicators).to eq(Alchemy::Admin::ElementStatusIndicators)
    end

    it "can be overridden with a custom component class" do
      stub_const("Custom::ElementStatus", Class.new)
      admin_components.element_status_indicators = "Custom::ElementStatus"
      expect(admin_components.element_status_indicators).to eq(Custom::ElementStatus)
    end
  end

  describe "#page_status_indicators" do
    it "defaults to the core page status indicators component" do
      expect(admin_components.page_status_indicators).to eq(Alchemy::Admin::PageStatusIndicators)
    end

    it "can be overridden with a custom component class" do
      stub_const("Custom::PageStatus", Class.new)
      admin_components.page_status_indicators = "Custom::PageStatus"
      expect(admin_components.page_status_indicators).to eq(Custom::PageStatus)
    end
  end
end
