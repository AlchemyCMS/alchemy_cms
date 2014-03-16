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

    describe 'validations' do
      context 'without essence description in elements.yml' do
        it 'should return an empty array' do
          essence.stub(:description).and_return nil
          expect(essence.validations).to eq([])
        end
      end

      context 'without validations defined in essence description in elements.yml' do
        it 'should return an empty array' do
          essence.stub(:description).and_return({name: 'test', type: 'EssenceText'})
          expect(essence.validations).to eq([])
        end
      end

      describe 'presence' do
        before do
          essence.stub(:description).and_return({'validate' => ['presence']})
        end

        context 'when the ingredient column is empty' do
          before { essence.update(essence.ingredient_column.to_sym => nil) }

          it 'should not be valid' do
            expect(essence).to_not be_valid
          end
        end

        context 'when the ingredient column is not nil' do
          before { essence.update(essence.ingredient_column.to_sym => ingredient_value) }

          it 'should be valid' do
            expect(essence).to be_valid
          end
        end
      end

      describe 'uniqueness' do
        before do
          essence.stub(:description).and_return({'validate' => ['uniqueness']})
          essence.update(essence.ingredient_column.to_sym => ingredient_value)
        end

        context 'when essence with same ingredient already exists' do
          before { essence.dup.save }

          it 'should not be valid' do
            expect(essence).to_not be_valid
          end
        end

        context 'when no essence with same ingredient exists' do
          it 'should be valid' do
            expect(essence).to be_valid
          end
        end
      end
    end

  end
end
