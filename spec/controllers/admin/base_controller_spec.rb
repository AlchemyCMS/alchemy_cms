require 'spec_helper'

describe Alchemy::Admin::BaseController, :type => :controller do

  describe '#options_from_params' do
    subject { controller.send(:options_from_params) }

    context "params[:options] is a JSON string" do
      before { allow(controller).to receive(:params).and_return(options: '{"hallo":"World"}') }

      it "parses the string into an object" do
        expect(subject).to be_an_instance_of(Hash)
        expect(subject).to eq({hallo: 'World'})
      end
    end

    context "params[:options] is already an object" do
      before { allow(controller).to receive(:params).and_return(options: {hallo: "World"}) }

      it "parses the string into an object" do
        expect(subject).to be_an_instance_of(Hash)
      end
    end

    context "params[:options] is not present" do
      before { allow(controller).to receive(:params).and_return({}) }

      it "returns ampty object" do
        expect(subject).to be_an_instance_of(Hash)
        expect(subject).to eq({})
      end
    end
  end

  describe '#raise_exception?' do
    subject { controller.send(:raise_exception?) }

    context 'in test mode' do
      before { Rails.env.stub(test?: true) }
      it { is_expected.to be_truthy }
    end

    context 'in page preview' do
      before { controller.stub(is_page_preview?: true) }
      it { is_expected.to be_truthy }
    end

    context 'not in test mode' do
      before { Rails.env.stub(test?: false) }
      it { is_expected.to be_falsey }

      context 'and not in page preview' do
        before { controller.stub(is_page_preview?: false) }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#is_page_preview?' do
    subject { controller.send(:is_page_preview?) }

    it { is_expected.to be_falsey }

    context 'is pages controller and show action' do
      before do
        controller.stub(controller_path: 'alchemy/admin/pages')
        controller.stub(action_name: 'show')
      end

      it { is_expected.to be_truthy }
    end
  end

end
