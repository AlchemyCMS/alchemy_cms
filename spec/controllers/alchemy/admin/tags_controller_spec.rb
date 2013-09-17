require 'spec_helper'

module Alchemy
  module Admin
    describe TagsController do
      before { sign_in(admin_user) }

      describe '#create' do
        context 'without required params' do
          render_views

          it "does not create tag" do
            post :create, tag: {name: ''}
            response.body.should have_content("can't be blank")
          end
        end

        context 'with required params' do
          it "creates tag and redirects to tags view" do
            expect {
              post :create, tag: {name: 'Foo'}
            }.to change { ActsAsTaggableOn::Tag.count }.by(1)
            response.should redirect_to admin_tags_path
          end
        end
      end

      describe '#edit' do
        let(:tag) { ActsAsTaggableOn::Tag.create(name: 'Sputz') }
        let(:another_tag) { ActsAsTaggableOn::Tag.create(name: 'Hutzl') }

        before { another_tag; tag }

        it "loads alls tags but not the one editing" do
          get :edit, id: tag.id
          assigns(:tags).should include(another_tag)
          assigns(:tags).should_not include(tag)
        end
      end

      describe '#update' do
        let(:tag) { ActsAsTaggableOn::Tag.create(name: 'Sputz') }

        it "changes tags name" do
          put :update, id: tag.id, tag: {name: 'Foo'}
          response.should redirect_to(admin_tags_path)
          expect(tag.reload.name).to eq('Foo')
        end

        context 'with merg_to param given' do
          let(:another_tag) { ActsAsTaggableOn::Tag.create(name: 'Hutzl') }

          it "replaces tag with other tag" do
            Alchemy::Tag.should_receive(:replace)
            ActsAsTaggableOn::Tag.any_instance.should_receive(:destroy)
            put :update, id: tag.id, tag: {merge_to: another_tag.id}
            response.should redirect_to(admin_tags_path)
          end
        end
      end
    end
  end
end
