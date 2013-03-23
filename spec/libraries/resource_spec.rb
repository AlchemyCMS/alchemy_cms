require 'rspec'
require File.dirname(__FILE__) + '/../../lib/alchemy/resource'

class Event
end

module Namespace1
  module Namespace2
    class Event
    end
  end
end

module Namespace
  class Event
  end
end

module EventEngine
  module Namespace
    class Event
    end
  end
end

# Alchemy's standard module definition. Only engine_name is relevant here
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

module Alchemy
  describe Resource do

    before :each do
      # stubbing an ActiveRecord::ModelSchema...
      columns = [
        mock(:column, {:name => 'name', :type => :string}),
        mock(:column, {:name => 'hidden_value', :type => :string}),
        mock(:column, {:name => 'description', :type => :string}),
        mock(:column, {:name => 'id', :type => :integer}),
        mock(:column, {:name => 'starts_at', :type => :datetime}),
        mock(:column, {:name => 'location_id', :type => :integer}),
        mock(:column, {:name => 'organizer_id', :type => :integer}),
      ]
      Event.stub(:columns).and_return columns
      #Alchemy::Config.stub(:get).and_return {}
    end

    describe "#initialize" do

      it "should set an instance variable that holds the controller path" do
        resource = Resource.new("admin/events")
        resource.instance_variable_get(:@controller_path).should == "admin/events"
      end

      context "when initialized with a module definition" do
        it "should set an instance variable that holds the module definition" do
          resource = Resource.new("admin/events", module_definition)
          resource.instance_variable_get(:@module_definition).should == module_definition
        end
      end

    end

    describe "#model_array" do

      it "splits the controller_path and returns it as array." do
        resource = Resource.new("namespace1/namespace2/events")
        resource.model_array.should eql(%W[namespace1 namespace2 events])
      end

      it "deletes 'admin' if found hence our model isn't in the admin-namespace by convention" do
        resource = Resource.new("admin/events")
        resource.model_array.should eql(%W[events])
      end

    end

    describe "#model" do
      it "should return the classified and constantized model name" do
        resource = Resource.new("admin/events")
        resource.model.should == Event
      end
    end

    describe "#model_name" do
      it "should return the model name (singularized and as a string)" do
        resource = Resource.new("admin/events")
        resource.model_name.should == "event"
      end
    end

    describe "#namespaced_model_name" do

      it "returns model_name with namespace (namespace_event for Namespace::Event), i.e. for use in forms" do
        namespaced_resource = Resource.new("admin/namespace/events")
        namespaced_resource.namespaced_model_name.should == 'namespace_event'
      end

      it "should equal model_name if model not namespaced" do
        namespaced_resource = Resource.new("admin/events")
        namespaced_resource.namespaced_model_name.should == namespaced_resource.model_name
      end

      it "should not include the engine's name" do
        namespaced_resource = Resource.new("admin/event_engine/namespace/events", module_definition)
        namespaced_resource.namespaced_model_name.should == 'namespace_event'
      end

    end

    describe "#engine_name" do
      it "should return the engine name of the module" do
        resource = Resource.new("admin/event_engine/namespace/events", module_definition)
        resource.engine_name.should == "event_engine"
      end
    end


    describe "#resources_name" do
      it "returns plural name (like events for model Event)" do
        resource = Resource.new("admin/events")
        resource.resources_name.should == "events"
      end
    end

    describe "#permission_scope" do
      it "returns a permission_scope usable in declarative authorization" do
        resource = Resource.new("admin/events")
        resource.permission_scope.should == :admin_events
      end
    end

    describe "#namespace_for_scope" do
      it "returns a scope for use in url_for-based path-helpers" do
        resource = Resource.new("admin/events")
        resource.namespace_for_scope.should == %W[admin]
      end
    end

    describe "#attributes" do
      let(:resource) { Resource.new("admin/events") }

      it "parses and returns the resource-model's attributes from ActiveRecord::ModelSchema" do
        resource.attributes.should == [
          {:name => "name", :type => :string},
          {:name => "hidden_value", :type => :string},
          {:name => "description", :type => :string},
          {:name => "starts_at", :type => :datetime},
          {:name => "location_id", :type => :integer},
          {:name => "organizer_id", :type => :integer},
        ]
      end

      context "when resource_relations is defined as class-method in the model" do
        before do
          Event.class_eval do
            def self.resource_relations
              {
                :location_id => {:attr_method => "location#name", :attr_type => :string},
                :organizer_id => {:attr_method => "organizer#name", :attr_type => :string}
              }
            end
          end
        end
        after do
          Event.class_eval do
            class << self
              undef resource_relations
            end
          end
        end

        # set while initializing, so new test object is needed...
        let(:resource) { Resource.new("admin/events") }

        it "uses the attribute location#name instead of location_id" do
          resource = Resource.new('admin/events')
          resource.attributes.detect { |a| a[:name] == "location#name" }.should == {:name => "location#name", :type => :string}
        end
        it "uses the attribute organizer#name instead of organizer_id" do
          resource.attributes.detect { |a| a[:name] == "organizer#name" }.should == {:name => "organizer#name", :type => :string}
        end
      end

      context "when resource_relation is not defined" do
        it "uses the attribute location_id" do
          resource.attributes.detect { |a| a[:name] == "location_id" }.should == {:name => "location_id", :type => :integer}
        end
      end

      it "skips attributes returned by skip_attributes" do
        # attr_accessor, hence skip_attributes= works
        resource.skip_attributes = %W[hidden_value]
        resource.attributes.should include({:name => "id", :type => :integer})
        resource.attributes.should_not include({:name => "hidden_value", :type => :string})
      end
    end
  end

  describe "#skip_attributes" do
    let(:resource) { Resource.new("admin/events") }

    it "returns a set of default attributes (Rails' default database attributes)" do
      # read from Resource::DEFAULT_SKIPPED_ATTRIBUTES
      default_skipped_attributes = %W[id updated_at created_at creator_id updater_id]
      resource.skip_attributes = default_skipped_attributes
    end

    context "when skip_attributes is defined as class-method in the model" do
      before do
        Event.class_eval do
          def self.skip_attributes
            %W[hidden_name]
          end
        end
      end
      after do
        Event.class_eval do
          class << self
            undef skip_attributes
          end
        end
      end

      it "returns the result of Model.skip_attributes" do
        custom_skipped_attributes = %W[hidden_name]
        resource.skip_attributes = custom_skipped_attributes
      end

    end

    describe "#searchable_attributes" do
      it "returns all attributes of type string" do
        resource = Resource.new("admin/events")
        resource.skip_attributes = []
        resource.searchable_attributes.should == [
          {:name => "name", :type => :string},
          {:name => "hidden_value", :type => :string},
          {:name => "description", :type => :string}
        ]
      end
    end

  end
end
