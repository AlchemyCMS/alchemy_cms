require 'spec_helper'

module Alchemy
  describe Resource do

    def module_definition
      {
        "name" => "event_list",
        "engine_name" => "event_engine",
        "navigation" => {
          "name" => "modules.event_list",
          "controller" => "admin/events",
          "action" => "index",
          "image" => "/assets/event_list_module.png"
        }
      }
    end

    def resource_relations
      {
        "event" => {
          "location_id" => {
            "attr_method" => "location#name",
            "attr_type" => "string"
          }
        }
      }
    end

    let(:resource) { Resource.new("admin/events", module_definition) }

    describe "#initialize" do
      it "should set an instance variable wich holds the controller path" do
        resource.instance_variable_get(:@controller_path).should == "admin/events"
      end

      it "should set an instance variable wich holds the module definition" do
        resource.instance_variable_get(:@module_definition).should == module_definition
      end

      it "should set the standard rails database attributes to be skipped" do
        resource.skip_attributes.should == %W[id updated_at created_at creator_id updater_id]
      end
    end

    describe "#model" do
      it "should return the classified and constantized model name" do
        resource.model.should == Event
      end
    end

    describe "#resources_name" do
      it "should return the resources name as a string" do
        resource.resources_name.should == "events"
      end
    end

    describe "#model_name" do
      it "should return the model name (singularized and as a string)" do
        resource.model_name.should == "event"
      end
    end

    describe "#permission_scope" do
      it "should set an instance variable wich holds the permission scope for declarative authorization" do
        resource.permission_scope
        resource.instance_variable_get(:@_permission).should == :admin_events
      end
    end

    describe "#namespace_for_scope" do
      it "should return the namespace" do
        resource.namespace_for_scope.should == ["admin"]
      end
    end

    describe "#attributes" do
      it "should not return the to be skipped attributes" do
        resource.class.const_get(:DEFAULT_SKIPPED_ATTRIBUTES).each do |skipped_attr|
          resource.attributes.detect{|a| a[:name] == skipped_attr }.should == nil
        end
      end

      context "when resource relations defined in the config.yml" do
        it "should use the attribute location#name instead of location_id" do
          Config.stub(:get).with(:resource_relations).and_return(resource_relations)
          resource.attributes.detect{|a| a[:name] == "location#name" }.should == {:name=>"location#name", :type=> :string}
        end
      end

      context "when no resource relations defined in the config.yml" do
        it "should use the attribute location_id" do
          Config.stub(:get).with(:resource_relations).and_return(nil)
          resource.attributes.detect{|a| a[:name] == "location_id" }.should == {:name=>"location_id", :type=> :integer}
        end
      end

    end

    describe "#engine_name" do
      it "should return the engine name of the module" do
        resource.engine_name.should == "event_engine"
      end
    end

    describe "#in_engine?" do
      it "should return true if the module is shipped within an engine" do
        resource.in_engine?.should == true
      end
    end

  end
end
