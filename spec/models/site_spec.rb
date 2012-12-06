require 'spec_helper'

module Alchemy
  describe Site do
    let(:site) { FactoryGirl.create(:site) }
    let(:another_site) { FactoryGirl.create(:site, name: 'Another Site', host: 'another.com') }

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
