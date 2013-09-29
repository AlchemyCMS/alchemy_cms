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

end
