require 'spec_helper'

module Alchemy
  describe Site do
    let(:site) { FactoryGirl.create(:site) }
    let(:another_site) { FactoryGirl.create(:site, name: 'Another Site', host: 'another.com') }

    describe 'new instances' do
      subject { FactoryGirl.build(:site) }

      it 'should start out with no languages' do
        expect(subject.languages).to be_empty
      end

      context 'when being saved' do
        context 'when it has no languages yet' do
          it 'should automatically create a default language' do
            subject.save!
            expect(subject.languages.length).to eq(1) # using count returns 0, although the resulting array has a length of 1 / O.o
            expect(subject.languages.first).to be_default
          end
        end

        context 'when it already has a language' do
          let(:language) { FactoryGirl.build(:language, site: nil) }
          before { subject.languages << language }

          it 'should not create any additional languages' do
            expect(subject.languages).to eq([language])

            expect { subject.save! }.
              to_not change(subject, "languages")
          end
        end
      end
    end

    describe '.find_for_host' do
      # No need to create a default site, as it has already been added through the seeds.
      # But let's add some more:
      #
      let(:default_site)    { Site.default }
      let!(:magiclabs_site) { FactoryGirl.create(:site, host: 'www.magiclabs.de', aliases: 'magiclabs.de magiclabs.com www.magiclabs.com') }

      subject { Site.find_for_host(host) }

      context "when the request doesn't match anything" do
        let(:host) { 'oogabooga.com' }
        it { is_expected.to eq(default_site) }
      end

      context "when the request matches a site's host field" do
        let(:host) { 'www.magiclabs.de' }
        it { is_expected.to eq(magiclabs_site) }
      end

      context "when the request matches one of the site's aliases" do
        let(:host) { 'magiclabs.com' }
        it { is_expected.to eq(magiclabs_site) }
      end

      context "when the request matches the site's first alias" do
        let(:host) { 'magiclabs.de' }
        it { is_expected.to eq(magiclabs_site) }
      end

      context "when the request matches the site's last alias" do
        let(:host) { 'www.magiclabs.com' }
        it { is_expected.to eq(magiclabs_site) }
      end

      context "when the request host matches only part of a site's aliases" do
        let(:host) { 'labs.com' }
        it { is_expected.to eq(default_site) }
      end
    end

    describe '.current' do
      context 'when set to a site' do
        before { Site.current = site }
        specify "Language should be scoped to that site" do
          expect(Language.all.to_sql).to match(/alchemy_languages.+site_id.+#{site.id}/)
        end
      end

      context 'when set to nil' do
        before { Site.current = nil }
        specify "Language should not be scoped to a site" do
          expect(Language.all.to_sql).not_to match(/alchemy_languages.+site_id.+#{site.id}/)
        end

        it "should return default site" do
          expect(Site.current).not_to be_nil
          expect(Site.current).to eq(Site.default)
        end
      end
    end

    describe '.definitions' do
      # To prevent memoization across specs
      before { Site.instance_variable_set("@definitions", nil) }

      subject { Site.definitions }

      context "with file present" do
        let(:definitions) { [{'name' => 'lala'}] }
        before { expect(YAML).to receive(:load_file).and_return(definitions) }
        it { is_expected.to eq(definitions) }
      end

      context "with empty file" do
        before { expect(YAML).to receive(:load_file).and_return(false) }
        it { is_expected.to eq([]) }
      end

      context "with no file present" do
        it { is_expected.to eq([]) }
      end
    end

    describe '.definitions' do
      # To prevent memoization across specs
      before { Site.instance_variable_set("@definitions", nil) }

      subject { Site.definitions }

      context "with file present" do
        let(:definitions) { [{'name' => 'lala'}] }
        before { expect(YAML).to receive(:load_file).and_return(definitions) }
        it { is_expected.to eq(definitions) }
      end

      context "with empty file" do
        before { expect(YAML).to receive(:load_file).and_return(false) }
        it { is_expected.to eq([]) }
      end

      context "with no file present" do
        it { is_expected.to eq([]) }
      end
    end

    describe '.definitions' do
      # To prevent memoization across specs
      before { Site.instance_variable_set("@definitions", nil) }

      subject { Site.definitions }

      context "with file present" do
        let(:definitions) { [{'name' => 'lala'}] }
        before { expect(YAML).to receive(:load_file).and_return(definitions) }
        it { is_expected.to eq(definitions) }
      end

      context "with empty file" do
        before { expect(YAML).to receive(:load_file).and_return(false) }
        it { is_expected.to eq([]) }
      end

      context "with no file present" do
        it { is_expected.to eq([]) }
      end
    end

    describe '.definitions' do
      # To prevent memoization across specs
      before { Site.instance_variable_set("@definitions", nil) }

      subject { Site.definitions }

      context "with file present" do
        let(:definitions) { [{'name' => 'lala'}] }
        before { expect(YAML).to receive(:load_file).and_return(definitions) }
        it { is_expected.to eq(definitions) }
      end

      context "with empty file" do
        before { expect(YAML).to receive(:load_file).and_return(false) }
        it { is_expected.to eq([]) }
      end

      context "with no file present" do
        it { is_expected.to eq([]) }
      end
    end

    describe '#current?' do
      subject { site.current? }

      context 'when Site.current is set to the same site' do
        before { Site.current = site }
        it { is_expected.to be_truthy }
      end

      context 'when Site.current is set to nil' do
        before { Site.current = nil }
        it { is_expected.to be_falsey }
      end

      context 'when Site.current is set to a different site' do
        before { Site.current = another_site }
        it { is_expected.to be_falsey }
      end
    end

    describe '#to_partial_path' do
      let(:site) {Site.new(name: 'My custom site')}

      it "returns the path to partial" do
        expect(site.to_partial_path).to eq("alchemy/site_layouts/my_custom_site")
      end
    end

    describe '#partial_name' do
      let(:site) {Site.new(name: 'My custom site')}

      it "returns the name for layout partial" do
        expect(site.partial_name).to eq("my_custom_site")
      end
    end

    describe '#definition' do
      let(:site) {Site.new(name: 'My custom site')}
      let(:definitions) { [{'name' => 'my_custom_site', 'page_layouts' => %w(standard)}] }

      it "returns layout definition from site_layouts.yml file" do
        allow(Site).to receive(:definitions).and_return(definitions)
        expect(site.definition).to eq(definitions.first)
      end
    end
  end
end
