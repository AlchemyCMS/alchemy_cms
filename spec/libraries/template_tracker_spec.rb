require 'spec_helper'

module Alchemy
  module CacheDigests
    describe TemplateTracker do
      subject { TemplateTracker.call(name, nil) }

      describe '#dependencies' do
        context 'with alchemy/pages/show given as template name' do
          let(:name) { 'alchemy/pages/show' }
          before { PageLayout.stub(:all).and_return([{'name' => 'intro'}, {'name' => 'contact'}]) }

          it "returns all page layout view partial names" do
            should include('alchemy/page_layouts/_intro', 'alchemy/page_layouts/_contact')
          end
        end

        context 'with a page layout given as template name' do
          let(:name) { 'alchemy/page_layouts/_intro' }
          let(:page_layout) { {'name' => 'intro', 'elements' => ['text']} }
          before { PageLayout.stub(:get).and_return(page_layout) }

          it "returns all element layout view partial names for that layout" do
            should include('alchemy/elements/_text_view')
          end

          context 'and page layout having cells' do
            let(:page_layout) { {'name' => 'intro', 'elements' => ['text'], 'cells' => ['header']} }

            it "returns all cell view partial names for that layout" do
              should include('alchemy/cells/_header')
            end
          end
        end

        context 'with a cell given as template name' do
          let(:name) { 'alchemy/cells/_header' }
          before { Cell.stub(:definition_for).and_return({'name' => 'header', 'elements' => ['text']}) }

          it "returns all element layout view partial names for that cell" do
            should include('alchemy/elements/_text_view')
          end
        end

        context 'with an element given as name' do
          let(:name) { 'alchemy/elements/_text_view' }
          let(:elements) { [{'name' => 'text', 'contents' => [{'type' => 'EssenceText'}]}] }

          context 'that is having a description' do
            before { Element.stub(:descriptions).and_return(elements) }

            it "returns all essence layout view partial names for that element" do
              should include('alchemy/essences/_essence_text_view')
            end

            context 'and element has picture_gallery enabled' do
              let(:elements) { [{'name' => 'text', 'picture_gallery' => true}] }

              it "has EssencePicture as template dependency" do
                should include('alchemy/essences/_essence_picture_view')
              end
            end

            context 'and element has available_contents defined' do
              let(:elements) { [{'name' => 'text', 'available_contents' => ['type' => 'EssenceFile']}] }

              it "has these essences as template dependency" do
                should include('alchemy/essences/_essence_file_view')
              end
            end
          end

          context 'that has no description' do
            before { Element.stub(:descriptions).and_return([]) }

            it "returns empty array" do
              should be_empty
            end
          end
        end

        context 'with not an alchemy template given as name' do
          let(:name) { 'shop/cart' }

          it "calls rails template tracker" do
            ActionView::DependencyTracker::ERBTracker.should_receive(:call).with(name, nil)
            subject
          end
        end
      end

    end
  end
end
