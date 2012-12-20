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
            subject.languages.count.should == 1
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
        specify "Language should be scoped to that site"
      end

      context 'when set to nil' do
        before { Site.current = nil }
        specify "Language should not be scoped to a site"
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
  end
end
