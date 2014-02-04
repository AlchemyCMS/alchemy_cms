require 'spec_helper'

module Alchemy
  describe EssenceText do
    let(:essence) { EssenceText.new }
    let(:ingredient_value) { 'Lorem ipsum' }

    it_behaves_like "an essence" do
      let(:essence)          { EssenceText.new }
      let(:ingredient_value) { 'Lorem ipsum' }
    end

    describe '#preview_text' do
      before do
        ingredient_column = essence.ingredient_column
        essence.send("#{ingredient_column}=", ingredient_value)
      end

      it "should return a preview text" do
        essence.preview_text.should == "#{ingredient_value}"
      end

      context "with given maxlength" do
        it "should return as much beginning characters as defined with maxlength" do
          essence.preview_text(2).should == "#{ingredient_value}"[0..1]
        end
      end

      context "with another preview_text_column defined" do
        before do
          essence.stub(:title).and_return('Title column')
          essence.stub(:preview_text_column).and_return(:title)
        end

        it "should use this column as preview text method" do
          essence.preview_text.should == 'Title column'
        end
      end
    end

    describe '#open_link_in_new_window?' do
      let(:essence) { EssenceText.new }
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
