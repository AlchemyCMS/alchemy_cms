require 'spec_helper'

module Alchemy
  describe ConfigLoader do
    context 'for elements' do
      subject { described_class.new('elements') }
      describe '#paths' do
        let(:paths) { subject.paths }

        it "is not empty" do
          expect(paths).to_not be_empty
        end

        it "contains at least one option" do
          expect(paths.length).to be > 0
        end

        it "points only to existing files" do
          paths.each do |path|
            expect(path.to_s).to end_with('config/alchemy/elements.yml')
            expect(path).to be_exist
          end
        end
      end

      describe '#load_all' do
        it "contains the elements for the app" do
          el_names = subject.load_all.map { |e| e['name'] }

          expect(el_names).to include('header')
          expect(el_names).to include('article')
          expect(el_names).to include('headline')
          expect(el_names).to include('all_you_can_eat')
        end
      end
    end
  end
end
