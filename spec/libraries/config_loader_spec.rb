require 'spec_helper'

module Alchemy
  describe ConfigLoader do
    shared_examples :paths_mentioning_app_last do
      it "is not empty" do
        expect(paths).to_not be_empty
      end

      it "contains at least one option" do
        expect(paths.length).to be > 0
      end

      describe "with all loaded engines providing a yml" do
        before do
          allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
        end

        it "contains more options" do
          # just a confirmation we faked existence the right way
          expect(paths.length).to be > 5
        end

        it "contains app's config path after any others" do
          # we have to choose one order and stick with it, #merge will take care of precedence
          expect(paths.last).to eq(app_config_path)
        end
      end
    end

    context 'for elements (Array)' do
      subject { described_class.new('elements') }
      describe '#paths' do
        let(:paths) { subject.paths }

        it "points only to existing files" do
          paths.each do |path|
            expect(path.to_s).to end_with('config/alchemy/elements.yml')
            expect(path).to be_exist
          end
        end

        it_behaves_like :paths_mentioning_app_last
      end

      describe '#file_name' do
        it "handle superfluous given extension" do
          extra = described_class.new('elements.yml')
          expect(extra.file_name).to eq(subject.file_name)
        end
      end

      describe '#load_all' do
        let(:el_names) { subject.load_all.map { |e| e['name'] } }
        it "contains the elements for the app" do
          expect(el_names).to include('header')
          expect(el_names).to include('article')
          expect(el_names).to include('headline')
          expect(el_names).to include('all_you_can_eat')
        end

        describe "with an engine providing a yml" do
          before do
            allow(subject).to receive(:paths).and_return(paths)
          end
          let(:paths) {[
            other_config_path,
            app_config_path,     # app is always mentioned last, see above
          ]}

          it "contains the app's elements before the engine's" do
            # because Element::Definitions#definition_by_name returns the first occurance
            expect(el_names.index('article')).to be < el_names.index('fake')
          end
        end
      end

      let(:app_config_path) { Pathname.new File.expand_path('../../dummy/config/alchemy/elements.yml', File.expand_path(__FILE__)) }
      let(:other_config_path) { Pathname.new File.expand_path('../../fixtures/config/alchemy/elements.yml', File.expand_path(__FILE__)) }
    end

    context 'for config.yml (Hash)' do
      subject { described_class.new('config') }
      let(:config) { subject.load_all }

      describe '#paths' do
        let(:paths) { subject.paths }
        it_behaves_like :paths_mentioning_app_last
      end

      describe '#load_all' do
        describe "with only engine providing a yml" do
          before do
            allow(subject).to receive(:paths).and_return(paths)
          end
          let(:paths) {[
            alchemy_gem_config_path,
            other_config_path,
          ]}

          it "uses the engine's config as a fallback" do
            expect(config['default_site']['name']).to eq("A site using our awesome Engine")
          end

          it "allows sparse config" do
            expect(config['default_site']).to have_key('host')
          end
        end

        describe "with app and engine providing a yml" do
          before do
            allow(subject).to receive(:paths).and_return(paths)
          end
          let(:paths) {[
            other_config_path,
            app_config_path,     # app is always mentioned last, see above
          ]}

          it "allows app to override deeply nested configuation initially set by engine" do
            # Hashes are just merged with app's last
            expect(config['default_site']['name']).to eq("A dummy app using Alchemy CMS")
          end
        end

        describe "when all configs are empty" do
          before do
            allow(subject).to receive(:load_file).and_return({})

            it "raises an error" do
              expect { subject.load_all }.to raise_error(LoadError)
            end
          end
        end
      end

      let(:alchemy_gem_config_path) { Pathname.new File.expand_path('../../..//config/alchemy/config.yml', File.expand_path(__FILE__)) }
      let(:app_config_path) { Pathname.new File.expand_path('../../dummy/config/alchemy/config.yml', File.expand_path(__FILE__)) }
      let(:other_config_path) { Pathname.new File.expand_path('../../fixtures/config/alchemy/config.yml', File.expand_path(__FILE__)) }
    end

  end
end
