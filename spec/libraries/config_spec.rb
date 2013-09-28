require 'spec_helper'

module Alchemy
  describe Config do

    describe ".get" do
      it "should call #show" do
        Config.should_receive(:show).and_return({})
        Config.get(:mailer)
      end

      it "should return the requested part of the config" do
        Config.should_receive(:show).and_return({'mailer' => {'setting' => 'true'}})
        expect(Config.get(:mailer)).to eq({'setting' => 'true'})
      end
    end

    describe '.main_app_config' do
      let(:main_app_config_path) { "#{Rails.root}/config/alchemy/config.yml" }

      it "should call and return .read_file with the correct config path" do
        Config.should_receive(:read_file).with(main_app_config_path).once.and_return({setting: 'true'})
        expect(Config.send(:main_app_config)).to eq({setting: 'true'})
      end
    end

    describe '.env_specific_config' do
      let(:env_specific_config_path) { "#{Rails.root}/config/alchemy/#{Rails.env}.config.yml" }

      it "should call and return .read_file with the correct config path" do
        Config.should_receive(:read_file).with(env_specific_config_path).once.and_return({setting: 'true'})
        expect(Config.send(:env_specific_config)).to eq({setting: 'true'})
      end
    end

    describe ".show" do
      context "when ivar @config was not set before" do
        before { Config.instance_variable_set("@config", nil) }

        it "should call and return .merge_configs!" do
          Config.should_receive(:merge_configs!).once.and_return({setting: 'true'})
          expect(Config.show).to eq({setting: 'true'})
        end
      end

      context "when ivar @config was already set" do
        before { Config.instance_variable_set("@config", {setting: 'true'}) }
        after { Config.instance_variable_set("@config", nil) }

        it "should have memoized the return value of .merge_configs!" do
          expect(Config.send(:show)).to eq({setting: 'true'})
        end
      end
    end

    describe '.read_file' do
      context 'when given path to yml file exists' do
        before { File.stub(:exists?).and_return(true) }

        it 'should call YAML.load_file with the given config path' do
          YAML.should_receive(:load_file).once.with('path/to/config.yml').and_return({})
          Config.send(:read_file, 'path/to/config.yml')
        end

        context 'but its empty' do
          before do
            File.stub(:exists?).with('empty_file.yml').and_return(true)
            YAML.stub(:load_file).and_return(false) # YAML.load_file returns false if file is empty.
          end

          it "should return an empty Hash" do
            expect(Config.send(:read_file, 'empty_file.yml')).to eq({})
          end
        end
      end

      context 'when given path to yml file does not exist' do
        it 'should return an empty Hash' do
          expect(Config.send(:read_file, 'does/not/exist.yml')).to eq({})
        end
      end
    end

    describe '.merge_configs!' do
      let(:config_1) do
        {setting_1: 'same', other_setting: 'something'}
      end

      let(:config_2) do
        {setting_1: 'same', setting_2: 'anything'}
      end

      it "should stringify the keys" do
        expect(Config.send(:merge_configs!, config_1)).to eq(config_1.stringify_keys!)
      end

      context 'when all passed configs are empty' do
        it "should raise an error" do
          expect { Config.send(:merge_configs!, {}) }.to raise_error
        end
      end

      context 'when configs containing same keys' do
        it "should merge them together" do
          expect(Config.send(:merge_configs!, config_1, config_2)).to eq(
            {'setting_1' => 'same', 'other_setting' => 'something', 'setting_2' => 'anything'}
          )
        end
      end
    end

  end

end
