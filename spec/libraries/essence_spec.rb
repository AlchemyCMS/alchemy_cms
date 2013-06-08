require 'spec_helper'

module Alchemy
  describe "ActsAsEssence" do
    #let(:element) { FactoryGirl.create(:element, :name => 'headline', :create_contents_after_create => true) }
    let(:essence) { Alchemy::EssenceText.new }

    describe '#ingredient=' do
      it 'should set the value to ingredient column' do
        essence.ingredient = 'Hallo'
        expect(essence.ingredient).to eq('Hallo')
      end
    end

    describe '#open_link_in_new_window?' do

      subject { essence.open_link_in_new_window? }

      context 'essence responds to link_taget' do
        context 'if link_target attribute is set to "blank"' do

          before { essence.link_target = 'blank' }

          it "should return true" do
            expect(subject).to eq(true)
          end
        end

        context 'if link_target attribute is not "blank"' do
          it "should return false" do
            expect(subject).to eq(false)
          end
        end
      end
    end

  end
end
