require 'rspec'
require File.dirname(__FILE__) + '/../../lib/alchemy/resource'

class Event
end


describe Alchemy::Resource do

  it "is initialized with a controller_path" do
    resource = Alchemy::Resource.new("admin/events")
    resource.should be_a Alchemy::Resource
  end
  it "can be can be initialized with an alchemy module_definition" do
    resource = Alchemy::Resource.new("admin/events", {'engine_name' => 'engine'})
    resource.should be_a Alchemy::Resource
  end

  describe "model_array" do
    it "splits the controller_path and returns it as array." do
      resource = Alchemy::Resource.new("namespace1/namespace2/events")
      resource.model_array.should eql(['namespace1', 'namespace2', 'events'])
    end

    it "deletes 'admin' if found hence our model isn't in the admin-namespace by convention" do
      resource = Alchemy::Resource.new("admin/events")
      resource.model_array.should eql(['events'])
    end
  end

  describe "instance methods" do
    before :each do
      @resource = Alchemy::Resource.new("admin/events")
    end

    describe "model" do
      it "returns resource's model-class" do
        @resource.model.should be(Event)
      end

      describe "resources_name" do
        it "returns plural name (like events for model Event)" do
          @resource.resources_name.should == 'events'
        end
      end

      describe "model_name" do
        it "returns model_name (like event for model Event" do
          @resource.model_name.should == 'event'
        end
      end

      describe "permission_scope" do
        it "should return the permissions_scope usable in declarative authorization" do
          @resource.permission_scope.should == :admin_events
        end
      end

      describe "namespace_for_scope" do
        it "returns a scope for use in url_for-based path-helpers" do
          @resource.namespace_for_scope.should == ['admin']
        end
      end

      describe "attributes" do
        before :each do
          ##stubbing an ActiveRecord::ModelSchema...
          columns = [
            mock(:column, {:name => 'name', :type => :string}),
            mock(:column, {:name => 'hidden_value', :type => :string}),
            mock(:column, {:name => 'description', :type => :string}),
            mock(:column, {:name => 'id', :type => :integer}),
            mock(:column, {:name => 'starts_at', :type => :datetime}),
          ]
          Event.stub(:columns).and_return columns
        end

        it "parses and returns the resource-model's attributes from ActiveRecord::ModelSchema" do
          @resource.attributes.should == [{:name => "name", :type => :string}, {:name => "hidden_value", :type => :string}, {:name => "description", :type => :string}, {:name => "starts_at", :type => :datetime}]
        end

        it "skips attributes mentioned in SKIP_ATTRIBUTES" do
          @resource.attributes.should_not include({:name => "id", :type => :integer})
          @resource.attributes.should include({:name => "hidden_value", :type => :string})
        end

        it "should prefer SKIP_ATTRIBUTES in model if defined" do
          Event.const_set :SKIP_ATTRIBUTES, %W[hidden_value]
          @resource.attributes.should include({:name => "id", :type => :integer})
          @resource.attributes.should_not include({:name => "hidden_value", :type => :string})
        end

        describe "searchable_attributes" do
          it "should return all attributes of type string" do
            Event.const_set :SKIP_ATTRIBUTES, []
            @resource.searchable_attributes.should == [{:name => "name", :type => :string}, {:name => "hidden_value", :type => :string}, {:name => "description", :type => :string}]
          end
        end
      end

    end

    describe "namespaced_model_name" do
      it "returns model_name with namespace (namespace_event for Namespace::Event), i.e. for use in forms" do
        namespaced_resource = Alchemy::Resource.new("admin/namespace/events")
        namespaced_resource.namespaced_model_name.should == 'namespace_event'
      end

      it "should not include the engine's name" do
        namespaced_resource = Alchemy::Resource.new("admin/engine/namespace/events", {'engine_name' => 'engine'})
        namespaced_resource.namespaced_model_name.should == 'namespace_event'
      end

      it "should equal model_name if model not namespaced" do
        namespaced_resource = Alchemy::Resource.new("admin/events")
        namespaced_resource.namespaced_model_name.should == namespaced_resource.model_name
      end
    end


  end
end
