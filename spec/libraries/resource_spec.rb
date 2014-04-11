require File.dirname(__FILE__) + '/../../lib/alchemy/resource'
require File.dirname(__FILE__) + '/../../lib/alchemy/errors'

class Party
end

module Namespace1
  module Namespace2
    class Party
    end
  end
end

module Namespace
  class Party
  end
end

module PartyEngine
  module Namespace
    class Party
    end
  end
end

# Alchemy's standard module definition. Only engine_name is relevant here
def module_definition
  {
    "name" => "party_list",
    "engine_name" => "party_engine",
    "navigation" => {
      "name" => "modules.party_list",
      "controller" => "/admin/parties",
      "action" => "index",
      "image" => "/assets/party_list_module.png"
    }
  }
end

module Alchemy
  describe Resource do
    let(:columns) do
      [
        double(:column, {name: 'name', type: :string, array: false}),
        double(:column, {name: 'hidden_value', type: :string, array: false}),
        double(:column, {name: 'description', type: :string, array: false}),
        double(:column, {name: 'id', type: :integer, array: false}),
        double(:column, {name: 'starts_at', type: :datetime, array: false}),
        double(:column, {name: 'location_id', type: :integer, array: false}),
        double(:column, {name: 'organizer_id', type: :integer, array: false}),
      ]
    end

    before :each do
      # stubbing an ActiveRecord::ModelSchema...
      Party.stub(:columns).and_return columns
    end

    describe "#initialize" do

      it "should set an instance variable that holds the controller path" do
        resource = Resource.new("admin/parties")
        resource.instance_variable_get(:@controller_path).should == "admin/parties"
      end

      context "when initialized with a module definition" do
        it "sets an instance variable that holds the module definition" do
          resource = Resource.new("admin/parties", module_definition)
          resource.instance_variable_get(:@module_definition).should == module_definition
        end
      end

      context "when initialized with a custom model" do
        it "sets @model to custom model" do
          CustomParty = Class.new
          resource = Resource.new("admin/parties", nil, CustomParty)
          resource.instance_variable_get(:@model).should == CustomParty
        end
      end

      context "when initialized without custom model" do
        it "guesses the model by the controller_path" do
          resource = Resource.new("admin/parties", nil, nil)
          resource.instance_variable_get(:@model).should == Party
        end
      end

      context "when model has alchemy_resource_relations defined" do
        before do
          Party.class_eval do
            def self.alchemy_resource_relations
              {location: {attr_method: 'name', type: 'string'}}
            end
          end
          Party.stub(:respond_to?).and_return { |arg|
            case arg
            when :reflect_on_all_associations
              then false
            when :alchemy_resource_relations
              then true
            end
          }
        end

        context ", but not an ActiveRecord association" do
          it "should raise error." do
            expect { Resource.new("admin/parties") }.to raise_error(MissingActiveRecordAssociation)
          end
        end

        after do
          Party.class_eval do
            class << self
              undef alchemy_resource_relations
            end
          end
        end
      end

    end

    describe "#resource_array" do

      it "splits the controller_path and returns it as array." do
        resource = Resource.new("namespace1/namespace2/parties")
        resource.resource_array.should eql(%W[namespace1 namespace2 parties])
      end

      it "deletes 'admin' if found hence our model isn't in the admin-namespace by convention" do
        resource = Resource.new("admin/parties")
        resource.resource_array.should eql(%W[parties])
      end

    end

    describe "#model" do
      it "returns the @model instance variable" do
        resource = Resource.new("admin/parties")
        resource.model.should == resource.instance_variable_get(:@model)
      end
    end

    describe "#resources_name" do
      it "returns plural name (like parties for model Party)" do
        resource = Resource.new("admin/parties")
        resource.resources_name.should == "parties"
      end
    end

    describe "#resource_name" do
      it "returns the resources name as singular" do
        resource = Resource.new("admin/parties")
        resource.resource_name.should == "party"
      end
    end

    describe "#namespaced_resource_name" do

      it "returns resource_name with namespace (namespace_party for Namespace::Party), i.e. for use in forms" do
        namespaced_resource = Resource.new("admin/namespace/parties")
        namespaced_resource.namespaced_resource_name.should == 'namespace_party'
      end

      it "equals resource_name if resource not namespaced" do
        namespaced_resource = Resource.new("admin/parties")
        namespaced_resource.namespaced_resource_name.should == 'party'
      end

      it "doesn't include the engine's name" do
        namespaced_resource = Resource.new("admin/party_engine/namespace/parties", module_definition)
        namespaced_resource.namespaced_resource_name.should == 'namespace_party'
      end

    end

    describe "#engine_name" do
      it "should return the engine name of the module" do
        resource = Resource.new("admin/party_engine/namespace/parties", module_definition)
        resource.engine_name.should == "party_engine"
      end
    end

    describe "#namespace_for_scope" do
      it "returns a scope for use in url_for-based path-helpers" do
        resource = Resource.new("admin/parties")
        resource.namespace_for_scope.should == %W[admin]
      end
    end

    describe "#attributes" do
      let(:resource) { Resource.new("admin/parties") }

      it "parses and returns the resource model's attributes from ActiveRecord::ModelSchema" do
        resource.attributes.should == [
          {:name => "name", :type => :string},
          {:name => "hidden_value", :type => :string},
          {:name => "description", :type => :string},
          {:name => "starts_at", :type => :datetime},
          {:name => "location_id", :type => :integer},
          {:name => "organizer_id", :type => :integer},
        ]
      end

      it "skips attributes returned by skip_attributes" do
        # attr_accessor, hence skip_attributes= works
        resource.skip_attributes = %W[hidden_value]
        resource.attributes.should include({:name => "id", :type => :integer})
        resource.attributes.should_not include({:name => "hidden_value", :type => :string})
      end
    end

    describe "#skip_attributes" do
      let(:resource) { Resource.new("admin/parties") }

      it "returns a set of default attributes (Rails' default database attributes)" do
        # read from Resource::DEFAULT_SKIPPED_ATTRIBUTES
        default_skipped_attributes = %W[id updated_at created_at creator_id updater_id]
        resource.skip_attributes = default_skipped_attributes
      end

      context "when skip_attributes is defined as class-method in the model" do
        before do
          Party.class_eval do
            def self.skip_attributes
              %W[hidden_name]
            end
          end
        end
        after do
          Party.class_eval do
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
        subject { resource.searchable_attributes }

        let(:resource) { Resource.new("admin/parties") }
        before { resource.skip_attributes = [] }

        it "returns all attributes of type string" do
          should == [
            {:name => "name", :type => :string},
            {:name => "hidden_value", :type => :string},
            {:name => "description", :type => :string}
          ]
        end

        context "with an array attribute" do
          let(:columns) do
            [
              double(:column, {name: 'name', type: :string, array: false}),
              double(:column, {name: 'languages', type: :string, array: true})
            ]
          end

          it "does not include this column" do
            should == [{name: "name", type: :string}]
          end
        end
      end
    end
  end
end
