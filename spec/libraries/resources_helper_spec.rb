require 'ostruct'
require File.dirname(__FILE__) + "/../../lib/alchemy/resource"
require File.dirname(__FILE__) + "/../../lib/alchemy/resources_helper"

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

    describe "resource_url_proxy" do
      it "should return the current proxy for use in url-helper-methods" do
        @controller.resource_url_proxy.should == 'main_app_proxy'
      end
      it "should return the engine's proxy object when resource is in engine" do
        @controller_for_engine = ResourcesControllerForEngine.new
        @controller_for_engine.stub('my_engine').and_return 'my_engine_proxy'
        @controller_for_engine.resource_url_proxy.should == 'my_engine_proxy'
      end
    end

    describe "resource_scope" do
      it "should provide an array containing a proxy and namespaces for use in url_for-based helper-methods" do
        @controller.resource_scope.should == %W[main_app_proxy admin]
      end
    end

    describe "resource_path" do

      it "should invoke polymorphic-path with correct scope and object" do
        my_resource_item = stub
        @controller.should_receive(:polymorphic_path).with(["main_app_proxy", "admin", my_resource_item], {})
        @controller.resource_path(my_resource_item)
      end

      it "use resource's class when no object is given" do
        @controller.should_receive(:polymorphic_path).with(["main_app_proxy", "admin", Namespace::MyResource], {})
        @controller.resource_path
      end

    end

    describe "resources_path method" do
      it "should invoke polymorphic-path with correct scope and resource class-name" do
        @controller.should_receive(:polymorphic_path).with(["main_app_proxy", "admin", Namespace::MyResource], {})
        @controller.resources_path
      end
    end

    it "should provide a new_resource_path method" do
      @controller.should_receive(:new_polymorphic_path).with(["main_app_proxy", "admin", Namespace::MyResource], {})
      @controller.new_resource_path
    end

    it "should provide a edit_resource_path method" do
      my_resource_item = stub
      @controller.should_receive(:edit_polymorphic_path).with(["main_app_proxy", "admin", my_resource_item], {})
      @controller.edit_resource_path(my_resource_item)
    end

  end

  describe "resource_instance_variable" do
    it "should return the resource_item" do
      @controller.resource_instance_variable.should == @resource_item
    end
  end

  describe "resources_instance_variable" do
    it "should return a collection of resource_items" do
      @controller.resources_instance_variable.should == [@resource_item]
    end
  end

  describe "resource_window_size" do
    it "should return overlay size string depending on resource attributes length" do
      @controller.stub(:resource_handler).and_return(OpenStruct.new(:attributes => OpenStruct.new(:length => 4)))
      @controller.resource_window_size.should == "420x260"
    end
  end
end
