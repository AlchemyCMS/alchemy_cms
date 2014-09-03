require File.dirname(__FILE__) + "/../../lib/alchemy/resource"
require File.dirname(__FILE__) + "/../../lib/alchemy/resources_helper"

module Namespace
  class MyResource
  end
end

module EngineResource
end

class ResourcesController
  include Alchemy::ResourcesHelper

  def resource_handler
    @resource_handler ||= Alchemy::Resource.new('admin/namespace/my_resources')
  end
end

class ResourcesControllerForEngine
  include Alchemy::ResourcesHelper

  def resource_handler
    @resource_handler ||= Alchemy::Resource.new('admin/engine_resources', {'engine_name' => 'my_engine'})
  end
end


describe Alchemy::ResourcesHelper do
  let(:controller) { ResourcesController.new }
  let(:resource_item) { double('resource-item') }

  before {
    allow(controller).to receive(:main_app).and_return 'main_app_proxy'
    controller.instance_variable_set('@my_resource', resource_item)
    controller.instance_variable_set('@my_resources', [resource_item])
  }

  describe "path-helpers" do
    describe "#resource_url_proxy" do
      it "returns the current proxy for url-helper-methods" do
        expect(controller.resource_url_proxy).to eq('main_app_proxy')
      end

      context "when resource is in engine" do
        let(:controller_for_engine) { ResourcesControllerForEngine.new }
        before { allow(controller_for_engine).to receive('my_engine').and_return('my_engine_proxy') }

        it "returns the engine's proxy" do
          expect(controller_for_engine.resource_url_proxy).to eq('my_engine_proxy')
        end
      end
    end

    describe "#resource_scope" do
      it "returns an array containing a proxy and namespaces for url_for-based helper-methods" do
        expect(controller.resource_scope).to eq(%W[main_app_proxy admin])
      end
    end

    describe "#resource_path" do
      it "invokes polymorphic-path with correct scope and object" do
        my_resource_item = double
        expect(controller).to receive(:polymorphic_path).with(["main_app_proxy", "admin", my_resource_item], {})
        controller.resource_path(my_resource_item)
      end

      it "uses resource_name when no object is given" do
        expect(controller).to receive(:polymorphic_path).with(["main_app_proxy", "admin", "my_resource"], {})
        controller.resource_path
      end
    end

    describe "#resources_path" do
      it "invokes polymorphic-path with correct scope and resources_name" do
        expect(controller).to receive(:polymorphic_path).with(["main_app_proxy", "admin", "my_resources"], {})
        controller.resources_path
      end
    end

    describe "#new_resource_path" do
      it "invokes new_polymorphic_path with correct scope and resource_name" do
        expect(controller).to receive(:new_polymorphic_path).with(["main_app_proxy", "admin", "my_resource"], {})
        controller.new_resource_path
      end
    end

    describe "#edit_resource_path" do
      it "invokes edit_polymorphic_path with correct scope and resource_name" do
        my_resource_item = double
        expect(controller).to receive(:edit_polymorphic_path).with(["main_app_proxy", "admin", my_resource_item], {})
        controller.edit_resource_path(my_resource_item)
      end
    end
  end

  describe "#resource_instance_variable" do
    it "returns the resource_item" do
      expect(controller.resource_instance_variable).to eq(resource_item)
    end
  end

  describe "#resources_instance_variable" do
    it "returns a collection of resource_items" do
      expect(controller.resources_instance_variable).to eq([resource_item])
    end
  end

  describe "#resource_window_size" do
    it "returns overlay size string depending on resource attributes length" do
      controller.stub_chain(:resource_handler, :attributes, :length).and_return(4)
      expect(controller.resource_window_size).to eq("420x260")
    end
  end

  describe "#render_attribute" do
    it "should return the value from resource attribute" do
      allow(resource_item).to receive(:name).and_return('my-name')
      expect(controller.render_attribute(resource_item, {name: 'name'})).to eq('my-name')
    end

    context "resource having a relation" do
      let(:associated_object) { double("location", title: 'Title of related object') }
      let(:associated_klass) { double("klass", find: associated_object) }
      let(:relation) {
        {
          attr_method: 'title',
          model_association: OpenStruct.new(klass: associated_klass)
        }
      }

      it "should return the value from the related object attribute" do
        allow(resource_item).to receive(:name).and_return('my-name')
        expect(controller.render_attribute(resource_item, {name: 'name', relation: relation})).to eq('Title of related object')
      end
    end
  end

  describe "#resource_name" do
    it "returns resource_handler.resource_name" do
      expect(controller.resource_name).to eq("my_resource")
    end
  end
end
