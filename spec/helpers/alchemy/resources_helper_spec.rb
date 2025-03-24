# frozen_string_literal: true

require "rails_helper"

module Namespace
  class MyResource
  end
end

module EngineResource
end

class ResourcesController
  include Alchemy::ResourcesHelper

  def resource_handler
    @resource_handler ||= Alchemy::Resource.new("admin/namespace/my_resources")
  end
end

class ResourcesControllerForEngine
  include Alchemy::ResourcesHelper

  def resource_handler
    @resource_handler ||= Alchemy::Resource.new("admin/engine_resources", {"engine_name" => "my_engine"})
  end
end

describe Alchemy::ResourcesHelper do
  let(:test_controller) { ResourcesController.new }
  let(:resource_item) { double("resource-item") }

  before {
    allow(test_controller).to receive(:main_app).and_return :main_app_proxy
    test_controller.instance_variable_set(:@my_resource, resource_item)
    test_controller.instance_variable_set(:@my_resources, [resource_item])
  }

  describe "path-helpers" do
    describe "#resource_url_proxy" do
      it "returns the current proxy for url-helper-methods" do
        expect(test_controller.resource_url_proxy).to eq(:main_app_proxy)
      end

      context "when resource is in engine" do
        let(:test_controller_for_engine) { ResourcesControllerForEngine.new }
        before { allow(test_controller_for_engine).to receive("my_engine").and_return("my_engine_proxy") }

        it "returns the engine's proxy" do
          expect(test_controller_for_engine.resource_url_proxy).to eq("my_engine_proxy")
        end
      end
    end

    describe "#resource_scope" do
      it "returns an array containing a proxy and namespaces for url_for-based helper-methods" do
        expect(test_controller.resource_scope).to eq(%i[main_app_proxy admin])
      end
    end

    describe "#resource_path" do
      it "invokes polymorphic-path with correct scope and object" do
        my_resource_item = double
        expect(test_controller).to receive(:polymorphic_path).with([:main_app_proxy, :admin, my_resource_item], {})
        test_controller.resource_path(my_resource_item)
      end

      it "uses resource_name when no object is given" do
        expect(test_controller).to receive(:polymorphic_path).with([:main_app_proxy, :admin, :namespace_my_resource], {})
        test_controller.resource_path
      end
    end

    describe "#resources_path" do
      it "invokes polymorphic-path with correct scope and resources_name" do
        expect(test_controller).to receive(:polymorphic_path).with([:main_app_proxy, :admin, :namespace_my_resources], {})
        test_controller.resources_path
      end
    end

    describe "#new_resource_path" do
      it "invokes new_polymorphic_path with correct scope and resource_name" do
        expect(test_controller).to receive(:new_polymorphic_path).with([:main_app_proxy, :admin, :namespace_my_resource], {})
        test_controller.new_resource_path
      end
    end

    describe "#edit_resource_path" do
      it "invokes edit_polymorphic_path with correct scope and resource_name" do
        my_resource_item = double
        expect(test_controller).to receive(:edit_polymorphic_path).with([:main_app_proxy, :admin, my_resource_item], {})
        test_controller.edit_resource_path(my_resource_item)
      end
    end
  end

  describe "#resource_instance_variable" do
    it "returns the resource_item" do
      expect(test_controller.resource_instance_variable).to eq(resource_item)
    end
  end

  describe "#resources_instance_variable" do
    it "returns a collection of resource_items" do
      expect(test_controller.resources_instance_variable).to eq([resource_item])
    end
  end

  describe "#resource_window_size" do
    it "returns overlay size string depending on resource attributes length" do
      allow(test_controller).to receive(:resource_handler).and_return double(attributes: double(length: 4))
      expect(test_controller.resource_window_size).to eq("480x260")
    end
  end

  describe "#render_attribute" do
    subject { test_controller.render_attribute(resource_item, attributes, options) }

    let(:options) { {} }
    let(:attributes) { {name: "name"} }

    it "should return the value from resource attribute" do
      allow(resource_item).to receive(:name).and_return("my-name")
      is_expected.to eq("my-name")
    end

    context "resource having a relation" do
      let(:associated_object) { double("location", title: "Title of related object") }
      let(:relation) do
        {
          attr_method: "title",
          name: "location"
        }
      end
      let(:attributes) do
        {
          name: "name",
          relation: relation
        }
      end

      before do
        allow(resource_item).to receive(:name).and_return("my-name")
        expect(resource_item).to receive(:location).and_return(associated_object)
      end

      it "should return the value from the related object attribute" do
        is_expected.to eq("Title of related object")
      end

      context "if the relation is empty" do
        let(:associated_object) { nil }

        it { is_expected.to eq("Not found") }
      end
    end

    context "with long values" do
      before do
        allow(resource_item).to receive(:name).and_return("*" * 51)
      end

      it "truncates the values" do
        expect(subject.length).to eq(50)
      end

      context "but with options[:truncate] set to 10" do
        let(:options) { {truncate: 10} }

        it "does not truncate the values" do
          expect(subject.length).to eq(10)
        end
      end

      context "but with options[:truncate] set to false" do
        let(:options) { {truncate: false} }

        it "does not truncate the values" do
          expect(subject.length).to eq(51)
        end
      end
    end

    context "format of timestamps" do
      let(:attributes) do
        {
          name: :created_at,
          type: :datetime
        }
      end

      let(:now) { Time.current.to_datetime }

      before do
        allow(resource_item).to receive(:created_at) { now }
      end

      it "formats the time with alchemy default format" do
        expect(test_controller).to receive(:l).with(now, format: :"alchemy.default")
        subject
      end

      context "with options[:datetime_format] set to other format" do
        let(:options) { {datetime_format: "OTHR"} }

        it "uses this format" do
          expect(test_controller).to receive(:l).with(now, format: "OTHR")
          subject
        end
      end
    end

    context "format of time values" do
      let(:attributes) do
        {
          name: :created_at,
          type: :time
        }
      end

      let(:now) { Time.current }

      before do
        allow(resource_item).to receive(:created_at) { now }
      end

      it "formats the time with alchemy datetime format" do
        expect(test_controller).to receive(:l).with(now, format: :"alchemy.time")
        subject
      end

      context "with options[:time_format] set to other format" do
        let(:options) { {time_format: "OTHR"} }

        it "uses this format" do
          expect(test_controller).to receive(:l).with(now, format: "OTHR")
          subject
        end
      end
    end

    context "format of boolean values" do
      let(:attributes) do
        {
          name: :foo,
          type: :boolean
        }
      end

      let(:enabled) { true }

      before do
        allow(resource_item).to receive(:foo) { enabled }
      end

      it "should respond with a check icon" do
        expect(subject).to eq("<alchemy-icon name=\"check\"></alchemy-icon>")
      end

      context "disabled attribute" do
        let(:enabled) { false }

        it "should show nothing" do
          expect(subject).to eq("")
        end
      end
    end
  end

  describe "#resource_attribute_field_options" do
    subject { test_controller.resource_attribute_field_options(attribute) }

    context "a boolean" do
      let(:attribute) do
        {
          type: :boolean
        }
      end

      it "just returns hint options" do
        is_expected.to match(
          hash_including(
            hint: nil
          )
        )
      end
    end

    context "a date" do
      let(:attribute) do
        {
          type: :date
        }
      end

      it "returns options for date picker" do
        is_expected.to match(
          hash_including(
            hint: nil,
            as: "date"
          )
        )
      end
    end

    context "a datetime" do
      let(:attribute) do
        {
          type: :datetime
        }
      end

      it "returns options for datetime picker" do
        is_expected.to match(
          hash_including(
            hint: nil,
            as: "datetime"
          )
        )
      end
    end

    context "a time" do
      let(:attribute) do
        {
          type: :time
        }
      end

      it "returns options for time picker" do
        is_expected.to match(
          hash_including(
            hint: nil,
            as: "time"
          )
        )
      end
    end

    context "a text" do
      let(:attribute) do
        {
          type: :text
        }
      end

      it "returns options for textarea" do
        is_expected.to match(
          hash_including(
            hint: nil,
            as: "text",
            input_html: {
              rows: 4
            }
          )
        )
      end
    end

    context "everything else" do
      let(:attribute) do
        {
          type: :foo
        }
      end

      it "returns options for text input field" do
        is_expected.to match(
          hash_including(
            hint: nil,
            as: "string"
          )
        )
      end
    end
  end

  describe "#resource_name" do
    it "returns resource_handler.resource_name" do
      expect(test_controller.resource_name).to eq("my_resource")
    end
  end
end
