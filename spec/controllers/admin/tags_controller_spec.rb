require 'spec_helper'

module Alchemy
  module Admin
    describe TagsController do
      before { authorize_user(:as_admin) }

      describe '#create' do
        context 'without required params' do
          render_views

          it "does not create tag" do
            alchemy_post :create, tag: {name: ''}
            expect(response.body).to have_content("can't be blank")
          end
        end

        context 'with required params' do
          it "creates tag and redirects to tags view" do
            expect {
              alchemy_post :create, tag: {name: 'Foo'}
            }.to change { ActsAsTaggableOn::Tag.count }.by(1)
            expect(response).to redirect_to admin_tags_path
          end
        end
      end

      describe '#edit' do
        let(:tag) { ActsAsTaggableOn::Tag.create(name: 'Sputz') }
        let(:another_tag) { ActsAsTaggableOn::Tag.create(name: 'Hutzl') }

        before { another_tag; tag }

        it "loads alls tags but not the one editing" do
          alchemy_get :edit, id: tag.id
          expect(assigns(:tags)).to include(another_tag)
          expect(assigns(:tags)).not_to include(tag)
        end
      end

      describe '#update' do
        let(:tag) { ActsAsTaggableOn::Tag.create(name: 'Sputz') }

        it "changes tags name" do
          alchemy_put :update, id: tag.id, tag: {name: 'Foo'}
          expect(response).to redirect_to(admin_tags_path)
          expect(tag.reload.name).to eq('Foo')
        end

        context 'with merg_to param given' do
          let(:another_tag) { ActsAsTaggableOn::Tag.create(name: 'Hutzl') }

          it "replaces tag with other tag" do
            expect(Alchemy::Tag).to receive(:replace)
            expect_any_instance_of(ActsAsTaggableOn::Tag).to receive(:destroy)
            alchemy_put :update, id: tag.id, tag: {merge_to: another_tag.id}
            expect(response).to redirect_to(admin_tags_path)
          end
        end
      end
    end
  end
end
