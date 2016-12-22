require 'spec_helper'

module Alchemy
  describe Config do
    describe ".get" do
      it "should call #show" do
        expect(Config).to receive(:show).and_return({})
        Config.get(:mailer)
      end

      it "should return the requested part of the config" do
        expect(Config).to receive(:show).and_return({'mailer' => {'setting' => 'true'}})
        expect(Config.get(:mailer)).to eq({'setting' => 'true'})
      end
    end

    describe ".show" do
      before do
        allow(Config).to receive(:loader).and_return(loader)
      end
      let(:loader) { instance_double 'ConfigLoader', load_all: loaded_config }
      let(:loaded_config) { {setting: 'true'} }

      context "when ivar @config was not set before" do
        before { Config.instance_variable_set("@config", nil) }

        it "should call and return .merge_configs!" do
          expect(Config.show).to eq(loaded_config)
        end
      end

      context "when ivar @config was already set" do
        before { Config.instance_variable_set("@config", {setting: 'true'}) }
        after { Config.instance_variable_set("@config", nil) }

        it "should have memoized the return value of loader.load_all" do
          expect(Config.send(:show)).to eq({setting: 'true'})
        end
      end
    end
  end
end
