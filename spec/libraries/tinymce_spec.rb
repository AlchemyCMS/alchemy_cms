require 'spec_helper'

module Alchemy
  describe Tinymce do

    describe '.init' do
      subject { Tinymce.init }

      it "returns the default config" do
        is_expected.to eq(Tinymce.class_variable_get('@@init'))
      end
    end

    describe '.init=' do
      let(:another_config) { {theme_advanced_buttons3: 'table'} }

      it "merges the default config with given config" do
        Tinymce.init = another_config
        expect(Tinymce.init).to include(another_config)
      end
    end

    context 'Methods for contents with custom tinymce config.' do
      let(:content_definition) do
        {
          'name' => 'text',
          'settings' => {
            'tinymce' => {
              'foo' => 'bar'
            }
          }
        }
      end

      let(:element_definition) do
        {
          'name' => 'article',
          'contents' => [content_definition]
        }
      end

      describe '.custom_config_contents' do
        subject { Tinymce.custom_config_contents }

        before do
          allow(Element).to receive(:definitions).and_return([element_definition])
          # Preventing memoization
          Tinymce.class_variable_set('@@custom_config_contents', nil)
        end

        it "returns an array of content definitions that contain custom tinymce config
        and element name" do
          is_expected.to be_an(Array)
          is_expected.to include({
            'element' => element_definition['name']
          }.merge(content_definition))
        end

        context 'with no contents having custom tinymce config' do
          let(:content_definition) do
            {'name' => 'text'}
          end

          it { is_expected.to eq([]) }
        end

        context 'with element definition having nil as contents value' do
          let(:element_definition) do
            {
              'name' => 'element',
              'contents' => nil
            }
          end

          it "returns empty array" do
            is_expected.to eq([])
          end
        end

        context 'with content settings tinymce set to true only' do
          let(:element_definition) do
            {
              'name' => 'element',
              'contents' => [
                'name' => 'headline',
                'settings' => {
                  'tinymce' => true
                }
              ]
            }
          end

          it "returns empty array" do
            is_expected.to eq([])
          end
        end

        context 'with a page given' do
          let(:page) { mock_model('Page') }
          subject { Tinymce.custom_config_contents(page) }

          it "only returns custom tinymce config for elements of that page" do
            expect(page).to receive(:element_definitions).and_return([element_definition])
            is_expected.to include(
              {'element' => element_definition['name']
            }.merge(content_definition))
          end
        end
      end
    end
  end
end
