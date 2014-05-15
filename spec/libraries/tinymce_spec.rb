require 'spec_helper'

module Alchemy
  describe Tinymce do

    describe '.init' do
      subject { Tinymce.init }

      it "returns the default config" do
        should eq(Tinymce.class_variable_get('@@init'))
      end
    end

    describe '.init=' do
      let(:another_config) { {theme_advanced_buttons3: 'table'} }

      it "merges the default config with given config" do
        Tinymce.init = another_config
        Tinymce.init.should include(another_config)
      end
    end

    context 'Methods for contents with custom tinymce config.' do
      let(:content_definition) { {'name' => 'text', 'settings' => {'tinymce' => {'foo' => 'bar'}}} }
      let(:element_definition) { {'name' => 'article', 'contents' => [content_definition]} }

      describe '.custom_config_contents' do
        subject { Tinymce.custom_config_contents }

        before do
          Element.stub(:definitions).and_return([element_definition])
          # Preventing memoization
          Tinymce.class_variable_set('@@custom_config_contents', nil)
        end

        it "returns an array of content definitions that contain custom tinymce config and element name" do
          should be_an(Array)
          should include({'element' => element_definition['name']}.merge(content_definition))
        end

        context 'with no contents having custom tinymce config' do
          let(:content_definition) { {'name' => 'text'} }
          it { should eq([]) }
        end

        context 'with element definition having nil as contents value' do
          let(:element_definition) { {'name' => 'element', 'contents' => nil} }

          it "returns empty array" do
            should eq([])
          end
        end

        context 'with a page given' do
          let(:page) { mock_model('Page') }
          subject { Tinymce.custom_config_contents(page) }

          it "only returns custom tinymce config for elements of that page" do
            expect(page).to receive(:element_definitions).and_return([element_definition])
            should include({'element' => element_definition['name']}.merge(content_definition))
          end
        end
      end
    end

  end
end
