require 'spec_helper'

module Namespace
  class MyResource
  end
end

module EngineResource
end

class ResourcesController
  def resource_handler
    @resource_handler = Alchemy::Resource.new('admin/namespace/my_resources')
  end

  include Alchemy::ResourcesHelper
end

class ResourcesControllerForEngine
  def resource_handler
    @resource_handler = Alchemy::Resource.new('admin/engine_resources', {'engine_name' => 'my_engine'})
  end

  include Alchemy::ResourcesHelper
end


describe Alchemy::ResourcesHelper do

  before :each do
    @controller = ResourcesController.new
    @controller.stub(:main_app).and_return 'main_app_proxy'
    @resource_item = stub('resource-item')
    @controller.instance_variable_set('@my_resource', @resource_item)
    @controller.instance_variable_set('@my_resources', [@resource_item])
  end

  describe "path-helpers" do

    describe "#resource_url_proxy" do

      it "returns the current proxy for url-helper-methods" do
        @controller.resource_url_proxy.should == 'main_app_proxy'
      end

      context "when resource is in engine" do
        it "returns the engine's proxy" do
          @controller_for_engine = ResourcesControllerForEngine.new
          @controller_for_engine.stub('my_engine').and_return 'my_engine_proxy'
          @controller_for_engine.resource_url_proxy.should == 'my_engine_proxy'
        end
      end

    end

    describe "#resource_scope" do
      it "returns an array containing a proxy and namespaces for url_for-based helper-methods" do
        @controller.resource_scope.should == %W[main_app_proxy admin]
      end
    end

    describe "#resource_path" do

      it "invokes polymorphic-path with correct scope and object" do
        my_resource_item = stub
        @controller.should_receive(:polymorphic_path).with(["main_app_proxy", "admin", my_resource_item], {})
        @controller.resource_path(my_resource_item)
      end

      it "uses resource_name when no object is given" do
        @controller.should_receive(:polymorphic_path).with(["main_app_proxy", "admin", "my_resource"], {})
        @controller.resource_path
      end

    end

    describe "#resources_path" do
      it "invokes polymorphic-path with correct scope and resources_name" do
        @controller.should_receive(:polymorphic_path).with(["main_app_proxy", "admin", "my_resources"], {})
        @controller.resources_path
      end
    end

    describe "#new_resource_path" do
      it "invokes new_polymorphic_path with correct scope and resource_name" do
        @controller.should_receive(:new_polymorphic_path).with(["main_app_proxy", "admin", "my_resource"], {})
        @controller.new_resource_path
      end
    end


    describe "#edit_resource_path" do
      it "invokes edit_polymorphic_path with correct scope and resource_name" do
        my_resource_item = stub
        @controller.should_receive(:edit_polymorphic_path).with(["main_app_proxy", "admin", my_resource_item], {})
        @controller.edit_resource_path(my_resource_item)
      end
    end

  end

  describe "#resource_instance_variable" do
    it "returns the resource_item" do
      @controller.resource_instance_variable.should == @resource_item
    end
  end

  describe "#resources_instance_variable" do
    it "returns a collection of resource_items" do
      @controller.resources_instance_variable.should == [@resource_item]
    end
  end

  describe "#resource_window_size" do
    it "returns overlay size string depending on resource attributes length" do
      @controller.stub(:resource_handler).and_return(OpenStruct.new(:attributes => OpenStruct.new(:length => 4)))
      @controller.resource_window_size.should == "420x260"
    end
  end

  describe "#render_attribute" do
    it "should return the value from resource attribute" do
      @resource_item.stub!(:name).and_return('my-name')
      @controller.render_attribute(@resource_item, {:name => 'name'}).should == 'my-name'
    end

    context "resource having a relation" do
      it "should return the value from the related object attribute" do
        @resource_item.stub!(:name).and_return('my-name')
        associated_object = double("location", :title => 'Title of related object')
        associated_klass = double("klass", :find => associated_object)
        relation = {:attr_method => :title, :model_association => OpenStruct.new(:klass => associated_klass)}
        @controller.render_attribute(@resource_item, {:name => 'name', :relation => relation}).should == 'Title of related object'
      end
    end
  end

  describe "#resource_model_name" do
    it "is deprecated" do
      ActiveSupport::Deprecation.should_receive(:warn)
      @controller.resource_model_name
    end
  end

  describe "#resource_name" do
    it "returns resource_handler.resource_name" do
      @controller.resource_name.should == "my_resource"
    end
  end

end
