require 'spec_helper'

describe Alchemy::Admin::BaseController do

  describe '#options_from_params' do
    subject { controller.send(:options_from_params) }

    context "params[:options] is a JSON string" do
      before { expect(controller).to receive(:params).at_least(:once).and_return(options: '{"hallo":"World"}') }

      it "parses the string into an object" do
        expect(subject).to be_an_instance_of(Hash)
        expect(subject).to eq({hallo: 'World'})
      end
    end

    context "params[:options] is already an object" do
      before { expect(controller).to receive(:params).at_least(:once).and_return(options: {hallo: "World"}) }

      it "parses the string into an object" do
        expect(subject).to be_an_instance_of(Hash)
      end
    end

    context "params[:options] is not present" do
      before { expect(controller).to receive(:params).at_least(:once).and_return({}) }

      it "returns ampty object" do
        expect(subject).to be_an_instance_of(Hash)
        expect(subject).to eq({})
      end
    end
  end

  describe '#raise_exception?' do
    subject { controller.send(:raise_exception?) }

    context 'in test mode' do
      before { expect(Rails.env).to receive(:test?).and_return true }
      it { is_expected.to be_truthy }
    end

    context 'not in test mode' do
      before { expect(Rails.env).to receive(:test?).and_return false }
      it { is_expected.to be_falsey }

      context 'and in page preview' do
        before { expect(controller).to receive(:is_page_preview?).and_return true }
        it { is_expected.to be_truthy }
      end

      context 'and not in page preview' do
        before { expect(controller).to receive(:is_page_preview?).and_return false }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#is_page_preview?' do
    subject { controller.send(:is_page_preview?) }

    it { is_expected.to be_falsey }

    context 'is pages controller and show action' do
      before do
        expect(controller).to receive(:controller_path).and_return('alchemy/admin/pages')
        expect(controller).to receive(:action_name).and_return('show')
      end

      it { is_expected.to be_truthy }
    end
  end

  context 'when current_alchemy_user is present' do
    let!(:page) { create(:alchemy_page) }
    let!(:user) { create(:alchemy_dummy_user, :as_admin) }

    before do
      allow(controller).to receive(:current_alchemy_user) { user }
      page.lock_to!(user)
    end

    it 'loads locked pages' do
      controller.send(:load_locked_pages)
      expect(assigns(:locked_pages)).to include(page)
    end
  end
end
