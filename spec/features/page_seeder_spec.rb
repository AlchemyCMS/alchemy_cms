# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Page seeding' do
  context 'when db/seeds/alchemy/pages.yml file is present' do
    let(:seeds_file) do
      'spec/fixtures/pages.yml'
    end

    before do
      FileUtils.mkdir_p(Rails.root.join('db/seeds/alchemy'))
      FileUtils.cp(seeds_file, Rails.root.join('db/seeds/alchemy/pages.yml'))
      Alchemy::Seeder.instance_variable_set(:@_page_yml, nil)
    end

    subject(:seed) do
      Alchemy::Shell.silence!
      Alchemy::Seeder.seed!
    end

    context 'when no pages are present yet' do
      before do
        Alchemy::Page.delete_all
      end

      it 'seeds pages', :aggregate_failures do
        seed
        expect(Alchemy::Page.find_by(name: 'Index')).to be_present
        expect(Alchemy::Page.find_by(name: 'Home')).to be_present
        expect(Alchemy::Page.find_by(name: 'About')).to be_present
        expect(Alchemy::Page.find_by(name: 'Contact')).to be_present
        expect(Alchemy::Page.find_by(name: 'Footer')).to be_present
      end

      context 'when more then one content root page is present' do
        let(:seeds_file) do
          'spec/fixtures/pages_with_two_roots.yml'
        end

        it 'aborts' do
          expect {
            expect { seed }.to output.to_stderr
          }.to raise_error(SystemExit)
        end
      end
    end

    context "when pages are already present" do
      let!(:page) { create(:alchemy_page) }

      it 'does not seed' do
        seed
        expect(Alchemy::Page.find_by(name: 'Home')).to_not be_present
      end
    end

    after do
      FileUtils.rm_rf(Rails.root.join('db/seeds'))
    end
  end
end
