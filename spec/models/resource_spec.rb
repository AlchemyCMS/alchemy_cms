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

    let(:resource) { Resource.new("admin/events", module_definition) }

    describe "#initialize" do
      it "should set an instance variable that holds the controller path" do
        resource.instance_variable_get(:@controller_path).should == "admin/events"
      end

      it "should set an instance variable that holds the module definition" do
        resource.instance_variable_get(:@module_definition).should == module_definition
      end

      it "should set the standard database attributes (rails defaults) to be skipped" do
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
      it "should set an instance variable that holds the permission scope for declarative authorization" do
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
      it "should not return the to-be-skipped attributes" do
        resource.class.const_get(:DEFAULT_SKIPPED_ATTRIBUTES).each do |skipped_attr|
          resource.attributes.detect { |a| a[:name] == skipped_attr }.should == nil
        end
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
              undef :skip_attributes
            end
          end
        end

        it "should not return the attributes returned by that method" do
          resource.attributes.detect { |a| a[:name] == 'hidden_name' }.should be_nil
          resource.attributes.detect { |a| a[:name] == 'name' }.should_not be_nil
        end
      end

      context "when resource_relations defined as class-method in the model" do
        before do
          @previous_setting = ::ActiveSupport::Deprecation.silenced
          ::ActiveSupport::Deprecation.silenced = true
          Event.class_eval do
            def self.resource_relations
              {
                :location => {:attr_method => "location#name", :attr_type => :string}
              }
            end
          end
        end

        it "should contain model_association from ActiveRecord::Reflections" do
          relation = resource.resource_relations[:location_id]
          relation.keys.should include(:model_association)
          relation[:model_association].class.should be(ActiveRecord::Reflection::AssociationReflection)
        end

        it "should skip default alchemy model associations" do
          resource.model_associations.collect(&:name).should_not include(*resource.class.const_get(:DEFAULT_SKIPPED_ASSOCIATIONS).map(&:to_sym))
        end

        it "should add _id to relation key" do
          resource.resource_relations[:location_id].should_not be_nil
        end

        it "should store the relation name" do
          relation = resource.resource_relations[:location_id]
          relation.keys.should include(:name)
          relation[:name].should == 'location'
        end

        context "with old hash delimited attr_method style" do
          it "should show deprecation warnings" do
            ActiveSupport::Deprecation.should_receive(:warn)
            resource.resource_relations
          end

          it "should return the last part as attr_method" do
            resource.resource_relations[:location_id][:attr_method].should == 'name'
          end
        end

        context "#attributes" do
          it "should contain the relation" do
            resource.attributes.detect { |a| a[:name] == 'location_id' }.keys.should include(:relation)
          end

          it "should have the relation column type as type" do
            resource.attributes.detect { |a| a[:name] == "location_id" }[:type].should == :string
          end
        end

        after do
          ::ActiveSupport::Deprecation.silenced = @previous_setting
          Event.class_eval do
            class << self
              undef :resource_relations
            end
          end
        end
      end

      context "when resource_relation is not defined" do
        it "should use the attribute location_id" do
          resource.attributes.detect { |a| a[:name] == "location_id" }.should == {:name => "location_id", :type => :integer}
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
