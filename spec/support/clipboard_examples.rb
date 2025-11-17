# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples_for "a controller with clipboard functionality" do |resource_type|
  let(:clipboard) { session[:alchemy_clipboard] = {} }
  let!(:language) { create(:alchemy_language) }

  describe "clipboard functionality" do
    context "with clipboard items" do
      let(:resource_in_clipboard) { create(:"alchemy_#{resource_type}", language: language) }

      before do
        allow_any_instance_of(described_class).to receive(:get_clipboard).with(resource_type.to_s.pluralize) do
          [{"id" => resource_in_clipboard.id.to_s, "action" => "copy"}]
        end
      end

      it "has clipboard items available" do
        get :new
        expect(controller.send(:clipboard)).to include({"id" => resource_in_clipboard.id.to_s, "action" => "copy"})
      end
    end

    context "without clipboard items" do
      it "has empty clipboard" do
        get :new
        expect(controller.send(:clipboard)).to eq([])
      end
    end

    context "with paste_from_clipboard in parameters" do
      let(:resource_in_clipboard) { create(:"alchemy_#{resource_type}", name: "Clipboard #{resource_type.to_s.humanize}", language: language) }
      let(:parent_resource) { create(:"alchemy_#{resource_type}", language: language) }
      let(:resource_params) do
        {
          name: "New #{resource_type.to_s.humanize}",
          language_id: language.id,
          parent_id: parent_resource.id
        }
      end

      before do
        # Ensure resources are created before testing
        resource_in_clipboard
        parent_resource
      end

      it "calls #{resource_type.to_s.classify}.copy_and_paste" do
        expect("Alchemy::#{resource_type.to_s.classify}".constantize).to receive(:copy_and_paste).with(
          resource_in_clipboard,
          parent_resource,
          resource_params[:name]
        ).and_call_original

        post :create, params: {
          resource_type.to_s.to_sym => resource_params,
          :paste_from_clipboard => resource_in_clipboard.id
        }
      end

      it "creates a copy of the #{resource_type}" do
        initial_count = "Alchemy::#{resource_type.to_s.classify}".constantize.count
        post :create, params: {
          resource_type.to_s.to_sym => resource_params,
          :paste_from_clipboard => resource_in_clipboard.id
        }

        expect("Alchemy::#{resource_type.to_s.classify}".constantize.count).to eq(initial_count + 1)
        new_resource = "Alchemy::#{resource_type.to_s.classify}".constantize.last
        expect(new_resource.name).to eq(resource_params[:name])
        expect(new_resource.parent).to eq(parent_resource)
      end

      it "redirects after paste" do
        post :create, params: {
          resource_type.to_s.to_sym => resource_params,
          :paste_from_clipboard => resource_in_clipboard.id
        }

        expect(response).to be_redirect
      end

      context "with child #{resource_type.to_s.pluralize}" do
        let(:child_resource) { create(:"alchemy_#{resource_type}", parent: resource_in_clipboard, name: "Child #{resource_type.to_s.humanize}") }

        before do
          child_resource # Create the child
        end

        it "copies all descendants" do
          initial_count = "Alchemy::#{resource_type.to_s.classify}".constantize.count
          post :create, params: {
            resource_type.to_s.to_sym => resource_params,
            :paste_from_clipboard => resource_in_clipboard.id
          }

          expect("Alchemy::#{resource_type.to_s.classify}".constantize.count).to eq(initial_count + 2) # parent + child
          new_parent = "Alchemy::#{resource_type.to_s.classify}".constantize.where(name: resource_params[:name]).first
          expect(new_parent.children.count).to eq(1)
          expect(new_parent.children.first.name).to eq("Child #{resource_type.to_s.humanize}")
        end
      end
    end
  end
end
