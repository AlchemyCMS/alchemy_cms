# frozen_string_literal: true

require "rails_helper"

module Alchemy
  module Admin
    describe TagsController do
      routes { Alchemy::Engine.routes }

      before { authorize_user(:as_admin) }

      describe "#index" do
        render_views

        let!(:picture) { create(:alchemy_picture, tag_list: "Foo,Bar") }

        it "renders index template" do
          get :index
          expect(response).to be_successful
        end

        context "with taggable missing" do
          before do
            picture.destroy
          end

          it "does not raise error" do
            get :index
            expect(response).to be_successful
          end
        end
      end

      describe "#create" do
        context "without required params" do
          render_views

          it "does not create tag" do
            post :create, params: {tag: {name: ""}}
            expect(response.body).to have_content("can't be blank")
          end
        end

        context "with required params" do
          it "creates tag and redirects to tags view" do
            expect {
              post :create, params: {tag: {name: "Foo"}}
            }.to change { Alchemy::Tag.count }.by(1)
            expect(response).to redirect_to admin_tags_path
          end
        end
      end

      describe "#edit" do
        let(:tag) { Alchemy::Tag.create(name: "Sputz") }
        let(:another_tag) { Alchemy::Tag.create(name: "Hutzl") }

        before do
          another_tag
          tag
        end

        it "loads alls tags but not the one editing", :aggregate_failures do
          get :edit, params: {id: tag.id}
          expect(assigns(:tags)).to include(another_tag)
          expect(assigns(:tags)).not_to include(tag)
        end
      end

      describe "#update" do
        let(:tag) { Alchemy::Tag.create(name: "Sputz") }

        it "changes tags name" do
          put :update, params: {id: tag.id, tag: {name: "Foo"}}
          expect(response).to redirect_to(admin_tags_path)
          expect(tag.reload.name).to eq("Foo")
        end

        context "with merg_to param given" do
          let(:another_tag) { Alchemy::Tag.create(name: "Hutzl") }

          it "replaces tag with other tag" do
            expect(Alchemy::Tag).to receive(:replace)
            expect_any_instance_of(Alchemy::Tag).to receive(:destroy)
            put :update, params: {id: tag.id, tag: {merge_to: another_tag.id}}
            expect(response).to redirect_to(admin_tags_path)
          end
        end
      end
    end
  end
end
