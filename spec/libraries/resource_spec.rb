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
      allow(Party).to receive(:columns).and_return columns
    end

    describe "#initialize" do
      it "sets the standard database attributes (rails defaults) to be skipped" do
        resource = Resource.new("admin/parties")
        expect(resource.skipped_attributes).to eq(%w(id updated_at created_at creator_id updater_id))
      end

      it "sets an instance variable that holds the controller path" do
        resource = Resource.new("admin/parties")
        expect(resource.instance_variable_get(:@controller_path)).to eq("admin/parties")
      end

      context "when initialized with a module definition" do
        it "sets an instance variable that holds the module definition" do
          expect(resource.instance_variable_get(:@module_definition)).to eq(module_definition)
        end
      end

      context "when initialized with a custom model" do
        it "sets @model to custom model" do
          CustomParty = Class.new
          resource = Resource.new("admin/parties", nil, CustomParty)
          expect(resource.instance_variable_get(:@model)).to eq(CustomParty)
        end
      end

      context "when initialized without custom model" do
        it "guesses the model by the controller_path" do
          resource = Resource.new("admin/parties", nil, nil)
          expect(resource.instance_variable_get(:@model)).to eq(Party)
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
            allow(Party).to receive(:respond_to?) do |arg|
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
        expect(resource.resource_array).to eql(%w(namespace1 namespace2 parties))
      end

      it "deletes 'admin' if found hence our model isn't in the admin-namespace by convention" do
        expect(resource.resource_array).to eql(%w(parties))
      end
    end

    describe "#model" do
      it "returns the @model instance variable" do
        expect(resource.model).to eq(resource.instance_variable_get(:@model))
      end
    end

    describe "#resources_name" do
      it "returns plural name (like parties for model Party)" do
        expect(resource.resources_name).to eq("parties")
      end
    end

    describe "#resource_name" do
      it "returns the resources name as singular" do
        expect(resource.resource_name).to eq("party")
      end
    end

    describe "#namespaced_resource_name" do
      it "returns resource_name with namespace (namespace_party for Namespace::Party), i.e. for use in forms" do
        namespaced_resource = Resource.new("admin/namespace/parties")
        expect(namespaced_resource.namespaced_resource_name).to eq('namespace_party')
      end

      it "equals resource_name if resource not namespaced" do
        namespaced_resource = Resource.new("admin/parties")
        expect(namespaced_resource.namespaced_resource_name).to eq('party')
      end

      it "doesn't include the engine's name" do
        namespaced_resource = Resource.new("admin/party_engine/namespace/parties", module_definition)
        expect(namespaced_resource.namespaced_resource_name).to eq('namespace_party')
      end
    end

    describe "#engine_name" do
      it "should return the engine name of the module" do
        resource = Resource.new("admin/party_engine/namespace/parties", module_definition)
        expect(resource.engine_name).to eq("party_engine")
      end
    end

    describe "#namespace_for_scope" do
      it "returns a scope for use in url_for based path helpers" do
        expect(resource.namespace_for_scope).to eq(%w(admin))
      end
    end

    describe "#attributes" do
      it "parses and returns the resource model's attributes from ActiveRecord::ModelSchema" do
        expect(resource.attributes).to eq([
          {:name => "name", :type => :string},
          {:name => "hidden_value", :type => :string},
          {:name => "description", :type => :string},
          {:name => "starts_at", :type => :datetime},
          {:name => "location_id", :type => :integer},
          {:name => "organizer_id", :type => :integer},
        ])
      end

      it "skips attributes returned by skipped_alchemy_resource_attributes" do
        # attr_accessor, hence skipped_alchemy_resource_attributes= works
        resource.skipped_attributes = %w(hidden_value)
        expect(resource.attributes).to include({:name => "id", :type => :integer})
        expect(resource.attributes).not_to include({:name => "hidden_value", :type => :string})
      end

      context "when resource_relations are not defined" do
        it "includes the attribute" do
          expect(resource.attributes.detect { |a| a[:name] == "location_id" }).to eq({:name => "location_id", :type => :integer})
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
          expect(resource.attributes.detect { |a| a[:name] == 'hidden_name' }).to be_nil
          expect(resource.attributes.detect { |a| a[:name] == 'name' }).not_to be_nil
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
        is_expected.to eq([
          {:name => "name", :type => :string},
          {:name => "hidden_value", :type => :string},
          {:name => "description", :type => :string}
        ])
      end

      context "with an array attribute" do
        let(:columns) do
          [
            double(:column, {name: 'name', type: :string, array: false}),
            double(:column, {name: 'languages', type: :string, array: true})
          ]
        end

        it "does not include this column" do
          is_expected.to eq([{name: "name", type: :string}])
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
          expect(relation.keys).to include(:model_association)
          expect(relation[:model_association].class).to be(ActiveRecord::Reflection::AssociationReflection)
        end

        it "adds '_id' to relation key" do
          expect(resource.resource_relations[:location_id]).not_to be_nil
        end

        it "stores the relation name" do
          relation = resource.resource_relations[:location_id]
          expect(relation.keys).to include(:name)
          expect(relation[:name]).to eq('location')
        end
      end

      describe '#model_associations' do
        it "skip default alchemy model associations" do
          expect(resource.model_associations.collect(&:name)).not_to include(*resource.class.const_get(:DEFAULT_SKIPPED_ASSOCIATIONS).map(&:to_sym))
        end
      end

      describe '#attributes' do
        it "contains the attribute of the related model" do
          expect(resource.attributes.detect { |a| a[:name] == 'location_id' }.keys).to include(:relation)
        end

        it "contains the related model's column type as type" do
          expect(resource.attributes.detect { |a| a[:name] == "location_id" }[:type]).to eq(:string)
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
        expect(resource.engine_name).to eq("party_engine")
      end
    end

    describe "#in_engine?" do
      it "should return true if the module is shipped within an engine" do
        expect(resource.in_engine?).to eq(true)
      end
    end

  end
end
