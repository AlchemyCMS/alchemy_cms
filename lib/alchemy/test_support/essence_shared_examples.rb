require 'spec_helper'

module Alchemy
  shared_examples_for "an essence" do

    let(:element) { Element.new }
    let(:content) { Content.new(name: 'foo') }
    let(:content_description) { {'name' => 'foo'} }

    it "touches the content after update" do
      essence.save
      content.update(essence: essence, essence_type: essence.class.name)
      d = content.updated_at
      content.essence.update(essence.ingredient_column.to_sym => ingredient_value)
      content.reload
      content.updated_at.should_not eq(d)
    end

    it "should have correct partial path" do
      underscored_essence = essence.class.name.demodulize.underscore
      expect(essence.to_partial_path).to eq("alchemy/essences/#{underscored_essence}_view")
    end

    describe '#description' do
      subject { essence.description }

      context 'without element' do
        it { should eq({}) }
      end

      context 'with element' do
        before { essence.stub(element: element) }

        context 'but without content descriptions' do
          it { should eq({}) }
        end

        context 'and content descriptions' do
          before do
            essence.stub(content: content)
          end

          context 'containing the content name' do
            before { element.stub(content_descriptions: [content_description]) }

            it "returns the content description" do
              should eq(content_description)
            end
          end

          context 'not containing the content name' do
            before { element.stub(content_descriptions: []) }

            it { should eq({}) }
          end
        end
      end
    end

    describe '#ingredient=' do
      it 'should set the value to ingredient column' do
        essence.ingredient = ingredient_value
        expect(essence.ingredient).to eq ingredient_value
      end
    end

    describe '#page' do
      let(:page)    { build_stubbed(:page) }
      let(:element) { build_stubbed(:element, page: page) }

      context 'essence has no element' do
        it "should return nil" do
          expect(essence.page).to eq(nil)
        end
      end

      it "should return the page the essence is placed on" do
        essence.stub(:element).and_return(element)
        expect(essence.page).to eq(page)
      end
    end

  end
end
