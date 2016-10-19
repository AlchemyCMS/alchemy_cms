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

    it 'seeds pages' do
      Alchemy::Seeder.seed!
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
          expect { Alchemy::Seeder.seed! }.to output.to_stderr
        }.to raise_error(SystemExit)
      end
    end

    after do
      FileUtils.rm_rf(Rails.root.join('db/seeds'))
    end
  end
end
