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
          allow(Party).to receive(:alchemy_resource_relations) do
            {location: {attr_method: 'name', type: 'string'}}
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
      subject { resource.attributes }

      it "parses and returns the resource model's attributes from ActiveRecord::ModelSchema" do
        expect(subject).to eq([
          {name: "name", type: :string},
          {name: "hidden_value", type: :string},
          {name: "description", type: :string},
          {name: "starts_at", type: :datetime},
          {name: "location_id", type: :integer},
          {name: "organizer_id", type: :integer},
        ])
      end

      it "skips the standard database attributes (rails defaults)" do
        expect(subject.map { |el| el[:name] }).not_to include(%w(id updated_at created_at creator_id updater_id))
      end

      it "skips attributes returned by skipped_alchemy_resource_attributes" do
        allow(Party).to receive(:skipped_alchemy_resource_attributes) { %w(hidden_value) }
        expect(subject).to include({:name => "id", :type => :integer})
        expect(subject).not_to include({:name => "hidden_value", :type => :string})
      end

      context "when resource_relations are not defined" do
        it "includes the attribute" do
          expect(subject.detect { |a| a[:name] == "location_id" }).to eq({:name => "location_id", :type => :integer})
        end
      end

      context "with custom additional attributes" do
        let(:custom_attributes) { [{name: "foo", type: :string}] }

        before do
          allow(Party).to receive(:additional_alchemy_resource_attributes) do
            custom_attributes
          end
        end

        it "includes the added attributes" do
          expect(subject).to include({name: "foo", type: :string})
        end
      end

      context "with restricted attributes set" do
        before do
          allow(Party).to receive(:restricted_alchemy_resource_attributes) do
            [{name: "name", type: :string}]
          end
        end

        it "should include the restricted attributes" do
          expect(subject).to include(name: "name", type: :string)
        end
      end
    end

    context "when `skipped_alchemy_resource_attributes` is defined as class method in the model" do
      let(:custom_skipped_attributes) { %w(hidden_name) }

      before do
        allow(Party).to receive(:skipped_alchemy_resource_attributes) do
          custom_skipped_attributes
        end
      end

      describe '#attributes' do
        it "does not return the attributes returned by that method" do
          expect(resource.attributes.detect { |a| a[:name] == 'hidden_name' }).to be_nil
          expect(resource.attributes.detect { |a| a[:name] == 'name' }).not_to be_nil
        end
      end
    end

    describe "#searchable_attributes" do
      subject { resource.searchable_attributes }

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

      context "with additional attributes set" do
        let(:custom_attributes) { [{name: "foo", type: "string"}] }

        before do
          allow(Party).to receive(:additional_alchemy_resource_attributes) do
            custom_attributes
          end
        end

        it "does not include the added attributes" do
          expect(subject).not_to include({name: "foo", type: "string"})
        end
      end
    end

    describe "#editable_attributes" do
      subject { resource.editable_attributes }

      let(:columns) do
        [
          double(:column, {name: 'name', type: :string}),
          double(:column, {name: 'title', type: :string}),
          double(:column, {name: 'synced_at', type: :datetime}),
          double(:column, {name: 'remote_record_id', type: :string})
        ]
      end

      before do
        allow(Party).to receive(:restricted_alchemy_resource_attributes) do
          [:synced_at, :remote_record_id]
        end
      end

      it "does not contain restricted attributes" do
        is_expected.to eq([{name: "name", type: :string}, {name: "title", type: :string}])
      end
    end

    context "when alchemy_resource_relations defined as class method in the model" do
      let(:resource) { Resource.new("admin/events") }

      before do
        allow(Event).to receive(:alchemy_resource_relations) do
          {
            :location => {:attr_method => "name", :attr_type => :string}
          }
        end
      end

      describe '#resource_relations' do
        it "should contain model_association from ActiveRecord::Reflections" do
          relation = resource.resource_relations[:location_id]
          expect(relation.keys).to include(:model_association)
          expect(relation[:model_association].class).to be(ActiveRecord::Reflection::BelongsToReflection)
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

      describe '#model_association_names' do
        it 'returns an array of association names' do
          expect(resource.model_association_names).to eq [:location]
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
