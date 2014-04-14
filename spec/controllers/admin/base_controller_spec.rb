require 'spec_helper'

describe Alchemy::Admin::BaseController do

  describe '#options_from_params' do
    subject { controller.send(:options_from_params) }

    context "params[:options] is a JSON string" do
      before { controller.stub(:params).and_return(options: '{"hallo":"World"}') }

      it "parses the string into an object" do
        expect(subject).to be_an_instance_of(Hash)
        expect(subject).to eq({hallo: 'World'})
      end
    end

    context "params[:options] is already an object" do
      before { controller.stub(:params).and_return(options: {hallo: "World"}) }

      it "parses the string into an object" do
        expect(subject).to be_an_instance_of(Hash)
      end
    end

    context "params[:options] is not present" do
      before { controller.stub(:params).and_return({}) }

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
      it { should be_true }
    end

    context 'in page preview' do
      before { controller.stub(is_page_preview?: true) }
      it { should be_true }
    end

    context 'not in test mode' do
      before { Rails.env.stub(test?: false) }
      it { should be_false }

      context 'and not in page preview' do
        before { controller.stub(is_page_preview?: false) }
        it { should be_false }
      end
    end
  end

  describe '#is_page_preview?' do
    subject { controller.send(:is_page_preview?) }

    it { should be_false }

    context 'is pages controller and show action' do
      before do
        controller.stub(controller_path: 'alchemy/admin/pages')
        controller.stub(action_name: 'show')
      end

      it { should be_true }
    end
  end

end
