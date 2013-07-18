require 'spec_helper'

module Alchemy
  describe Site do
    let(:site) { FactoryGirl.create(:site) }
    let(:another_site) { FactoryGirl.create(:site, name: 'Another Site', host: 'another.com') }

    describe 'new instances' do
      subject { FactoryGirl.build(:site) }

      it 'should start out with no languages' do
        subject.languages.should be_empty
      end

      context 'when being saved' do
        context 'when it has no languages yet' do
          it 'should automatically create a default language' do
            subject.save!
            subject.languages.length.should == 1 # using count returns 0, although the resulting array has a length of 1 / O.o
            subject.languages.first.should be_default
          end
        end

        context 'when it already has a language' do
          let(:language) { FactoryGirl.build(:language, site: nil) }
          before { subject.languages << language }

          it 'should not create any additional languages' do
            subject.languages.should == [language]

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
        it { should == default_site }
      end

      context "when the request matches a site's host field" do
        let(:host) { 'www.magiclabs.de' }
        it { should == magiclabs_site }
      end

      context "when the request matches one of the site's aliases" do
        let(:host) { 'magiclabs.com' }
        it { should == magiclabs_site }
      end

      context "when the request matches the site's first alias" do
        let(:host) { 'magiclabs.de' }
        it { should == magiclabs_site }
      end

      context "when the request matches the site's last alias" do
        let(:host) { 'www.magiclabs.com' }
        it { should == magiclabs_site }
      end

      context "when the request host matches only part of a site's aliases" do
        let(:host) { 'labs.com' }
        it { should == default_site }
      end
    end

    describe '.current' do
      context 'when set to a site' do
        before { Site.current = site }
        specify "Language should be scoped to that site" do
          Language.all.to_sql.should match(/alchemy_languages.+site_id.+#{site.id}/)
        end
      end

      context 'when set to nil' do
        before { Site.current = nil }
        specify "Language should not be scoped to a site" do
          Language.all.to_sql.should_not match(/alchemy_languages.+site_id.+#{site.id}/)
        end

        it "should return default site" do
          Site.current.should_not be_nil
          Site.current.should == Site.default
        end
      end
    end

    describe '.layout_definitions' do
      # To prevent memoization across specs
      before { Site.instance_variable_set("@layout_definitions", nil) }

      subject { Site.layout_definitions }

      context "with file present" do
        let(:definitions) { [{'name' => 'lala'}] }
        before { YAML.should_receive(:load_file).and_return(definitions) }
        it { should == definitions }
      end

      context "with empty file" do
        before { YAML.should_receive(:load_file).and_return(false) }
        it { should == [] }
      end

      context "with no file present" do
        it { should == [] }
      end
    end

    describe '.layout_definitions' do
      # To prevent memoization across specs
      before { Site.instance_variable_set("@layout_definitions", nil) }

      subject { Site.layout_definitions }

      context "with file present" do
        let(:definitions) { [{'name' => 'lala'}] }
        before { YAML.should_receive(:load_file).and_return(definitions) }
        it { should == definitions }
      end

      context "with empty file" do
        before { YAML.should_receive(:load_file).and_return(false) }
        it { should == [] }
      end

      context "with no file present" do
        it { should == [] }
      end
    end

    describe '.layout_definitions' do
      # To prevent memoization across specs
      before { Site.instance_variable_set("@layout_definitions", nil) }

      subject { Site.layout_definitions }

      context "with file present" do
        let(:definitions) { [{'name' => 'lala'}] }
        before { YAML.should_receive(:load_file).and_return(definitions) }
        it { should == definitions }
      end

      context "with empty file" do
        before { YAML.should_receive(:load_file).and_return(false) }
        it { should == [] }
      end

      context "with no file present" do
        it { should == [] }
      end
    end

    describe '.layout_definitions' do
      # To prevent memoization across specs
      before { Site.instance_variable_set("@layout_definitions", nil) }

      subject { Site.layout_definitions }

      context "with file present" do
        let(:definitions) { [{'name' => 'lala'}] }
        before { YAML.should_receive(:load_file).and_return(definitions) }
        it { should == definitions }
      end

      context "with empty file" do
        before { YAML.should_receive(:load_file).and_return(false) }
        it { should == [] }
      end

      context "with no file present" do
        it { should == [] }
      end
    end

    describe '#current?' do
      subject { site.current? }

      context 'when Site.current is set to the same site' do
        before { Site.current = site }
        it { should be_true }
      end

      context 'when Site.current is set to nil' do
        before { Site.current = nil }
        it { should be_false }
      end

      context 'when Site.current is set to a different site' do
        before { Site.current = another_site }
        it { should be_false }
      end
    end

    describe '#to_partial_path' do
      let(:site) {Site.new(name: 'My custom site')}

      it "returns the path to partial" do
        site.to_partial_path.should == "alchemy/site_layouts/my_custom_site"
      end
    end

    describe '#layout_partial_name' do
      let(:site) {Site.new(name: 'My custom site')}

      it "returns the name for layout partial" do
        site.layout_partial_name.should == "my_custom_site"
      end
    end

    describe '#layout_definition' do
      let(:site) {Site.new(name: 'My custom site')}
      let(:definitions) { [{'name' => 'my_custom_site', 'page_layouts' => %w(standard)}] }

      it "returns layout definition from site_layouts.yml file" do
        Site.stub(:layout_definitions).and_return(definitions)
        site.layout_definition.should == definitions.first
      end
    end

  end
end
