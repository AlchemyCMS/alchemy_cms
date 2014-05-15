require 'spec_helper'

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

module Alchemy
  describe Resource do
    # Alchemy's standard module definition. Only engine_name is relevant here
    let(:module_definition) do
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

    let(:resource) { Resource.new("admin/parties", module_definition) }

    before :each do
      # stubbing an ActiveRecord::ModelSchema...
      Party.stub(:columns).and_return columns
    end

    describe "#initialize" do
      it "sets the standard database attributes (rails defaults) to be skipped" do
        resource = Resource.new("admin/parties")
        resource.skipped_attributes.should == %w(id updated_at created_at creator_id updater_id)
      end

      it "sets an instance variable that holds the controller path" do
        resource = Resource.new("admin/parties")
        resource.instance_variable_get(:@controller_path).should == "admin/parties"
      end

      context "when initialized with a module definition" do
        it "sets an instance variable that holds the module definition" do
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
        end

        context ", but not an ActiveRecord association" do
          before do
            Party.stub(:respond_to?).and_return do |arg|
              case arg
              when :reflect_on_all_associations
                then false
              when :alchemy_resource_relations
                then true
              end
            end
          end

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
        resource.resource_array.should eql(%w(namespace1 namespace2 parties))
      end

      it "deletes 'admin' if found hence our model isn't in the admin-namespace by convention" do
        resource.resource_array.should eql(%w(parties))
      end
    end

    describe "#model" do
      it "returns the @model instance variable" do
        resource.model.should == resource.instance_variable_get(:@model)
      end
    end

    describe "#resources_name" do
      it "returns plural name (like parties for model Party)" do
        resource.resources_name.should == "parties"
      end
    end

    describe "#resource_name" do
      it "returns the resources name as singular" do
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
      it "returns a scope for use in url_for based path helpers" do
        resource.namespace_for_scope.should == %w(admin)
      end
    end

    describe "#attributes" do
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

      it "skips attributes returned by skipped_alchemy_resource_attributes" do
        # attr_accessor, hence skipped_alchemy_resource_attributes= works
        resource.skipped_attributes = %w(hidden_value)
        resource.attributes.should include({:name => "id", :type => :integer})
        resource.attributes.should_not include({:name => "hidden_value", :type => :string})
      end

      context "when resource_relations are not defined" do
        it "includes the attribute" do
          resource.attributes.detect { |a| a[:name] == "location_id" }.should == {:name => "location_id", :type => :integer}
        end
      end
    end

    context "when `skipped_alchemy_resource_attributes` is defined as class method in the model" do
      before do
        Party.class_eval do
          def self.skipped_alchemy_resource_attributes
            %w(hidden_name)
          end
        end
      end

      describe '#attributes' do
        it "does not return the attributes returned by that method" do
          resource.attributes.detect { |a| a[:name] == 'hidden_name' }.should be_nil
          resource.attributes.detect { |a| a[:name] == 'name' }.should_not be_nil
        end
      end

      describe '#skipped_attributes' do
        it "returns the result of Model.skipped_alchemy_resource_attributes" do
          custom_skipped_attributes = %w(hidden_name)
          resource.skipped_attributes = custom_skipped_attributes
        end
      end

      after do
        Party.class_eval do
          class << self
            undef skipped_alchemy_resource_attributes
          end
        end
      end
    end

    describe "#searchable_attributes" do
      subject { resource.searchable_attributes }

      before { resource.skipped_attributes = [] }

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

    context "when alchemy_resource_relations defined as class method in the model" do
      let(:resource) { Resource.new("admin/events") }

      before do
        Event.class_eval do
          def self.alchemy_resource_relations
            {
              :location => {:attr_method => "name", :attr_type => :string}
            }
          end
        end
      end

      describe '#resource_relations' do
        it "should contain model_association from ActiveRecord::Reflections" do
          relation = resource.resource_relations[:location_id]
          relation.keys.should include(:model_association)
          relation[:model_association].class.should be(ActiveRecord::Reflection::AssociationReflection)
        end

        it "adds '_id' to relation key" do
          resource.resource_relations[:location_id].should_not be_nil
        end

        it "stores the relation name" do
          relation = resource.resource_relations[:location_id]
          relation.keys.should include(:name)
          relation[:name].should == 'location'
        end
      end

      describe '#model_associations' do
        it "skip default alchemy model associations" do
          resource.model_associations.collect(&:name).should_not include(*resource.class.const_get(:DEFAULT_SKIPPED_ASSOCIATIONS).map(&:to_sym))
        end
      end

      describe '#attributes' do
        it "contains the attribute of the related model" do
          resource.attributes.detect { |a| a[:name] == 'location_id' }.keys.should include(:relation)
        end

        it "contains the related model's column type as type" do
          resource.attributes.detect { |a| a[:name] == "location_id" }[:type].should == :string
        end
      end

      after do
        Event.class_eval do
          class << self
            undef :alchemy_resource_relations
          end
        end
      end
    end

    describe "#engine_name" do
      it "should return the engine name of the module" do
        resource.engine_name.should == "party_engine"
      end
    end

    describe "#in_engine?" do
      it "should return true if the module is shipped within an engine" do
        resource.in_engine?.should == true
      end
    end

  end
end
