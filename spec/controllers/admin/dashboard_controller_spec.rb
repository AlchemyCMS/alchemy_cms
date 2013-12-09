require 'spec_helper'

module Alchemy
  describe Admin::DashboardController do
    let(:user) { admin_user }

    before { sign_in(user) }

    describe '#index' do
      before do
        Page.stub_chain(:from_current_site, :all_last_edited_from).and_return([])
        Page.stub_chain(:from_current_site, :all_locked).and_return([])
      end

      it "assigns @last_edited_pages" do
        get :index
        expect(assigns(:last_edited_pages)).to eq([])
      end

      it "assigns @locked_pages" do
        get :index
        expect(assigns(:locked_pages)).to eq([])
      end

      context 'with user class having logged_in scope' do
        context 'with other users online' do
          let(:another_user) { mock_model('DummyUser') }

          before do
            Alchemy.user_class.should_receive(:logged_in).and_return([another_user])
          end

          it "assigns @online_users" do
            get :index
            expect(assigns(:online_users)).to eq([another_user])
          end
        end

        context 'without other users online' do
          it "does not assign @online_users" do
            get :index
            expect(assigns(:online_users)).to eq([])
          end
        end
      end

      context 'user having signed in before' do
        before do
          user.should_receive(:sign_in_count).and_return(5)
          user.should_receive(:last_sign_in_at).and_return(Time.now)
        end

        it "assigns @first_time" do
          get :index
          expect(assigns(:first_time)).to eq(false)
        end
      end

      it "assigns @sites" do
        get :index
        expect(assigns(:sites)).to eq(Site.all)
      end
    end

    describe '#info' do
      it "assigns @alchemy_version with the current Alchemy version" do
        get :info
        expect(assigns(:alchemy_version)).to eq(Alchemy.version)
      end
    end

    describe '#update_check' do
      context "if current Alchemy version equals the latest released version or it is newer" do
        before {
          controller.stub(:latest_alchemy_version).and_return('2.6')
          Alchemy.stub(:version).and_return("2.6")
        }

        it "should render 'false'" do
          get :update_check
          expect(response.body).to eq('false')
        end
      end

      context "if current Alchemy version is older than latest released version" do
        before {
          controller.stub(:latest_alchemy_version).and_return('2.6')
          Alchemy.stub(:version).and_return("2.5")
        }

        it "should render 'true'" do
          get :update_check
          expect(response.body).to eq('true')
        end
      end

      context "requesting rubygems.org" do
        before {
          Net::HTTP.any_instance.stub(:request).and_return(
            OpenStruct.new({code: '200', body: '[{"number": "2.6"}, {"number": "2.5"}]'})
          )
          Alchemy.stub(:version).and_return("2.6")
        }

        it "should have response code of 200" do
          get :update_check
          expect(response.code).to eq('200')
        end
      end

      context "requesting github.com" do
        before {
          controller.stub(:query_rubygems).and_return(OpenStruct.new({code: '503'}))
          Net::HTTP.any_instance.stub(:request).and_return(
            OpenStruct.new({code: '200', body: '[{"name": "2.6"}, {"name": "2.5"}]'})
          )
        }

        it "should have response code of 200" do
          get :update_check
          expect(response.code).to eq('200')
        end
      end

      context "rubygems.org and github.com are unavailable" do
        before {
          Net::HTTP.any_instance.stub(:request).and_return(
            OpenStruct.new({code: '503'})
          )
        }

        it "should have status code 503" do
          get :update_check
          expect(response.code).to eq('503')
        end
      end
    end

  end
end
