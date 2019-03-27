# frozen_string_literal: true

require 'rails_helper'

module Alchemy
  module CacheDigests
    describe TemplateTracker do
      subject { TemplateTracker.call(name, nil) }

      describe '#dependencies' do
        context 'with alchemy/pages/show given as template name' do
          let(:name) { 'alchemy/pages/show' }
          before { allow(PageLayout).to receive(:all).and_return([{'name' => 'intro'}, {'name' => 'contact'}]) }

          it "returns all page layout view partial names" do
            is_expected.to include('alchemy/page_layouts/_intro', 'alchemy/page_layouts/_contact')
          end
        end

        context 'with a page layout given as template name' do
          let(:name) { 'alchemy/page_layouts/_intro' }
          let(:page_layout) { {'name' => 'intro', 'elements' => ['text']} }
          before { allow(PageLayout).to receive(:get).and_return(page_layout) }

          it "returns all element layout view partial names for that layout" do
            is_expected.to include('alchemy/elements/_text_view')
          end
        end

        context 'with an element given as name' do
          let(:name) { 'alchemy/elements/_text_view' }
          let(:elements) { [{'name' => 'text', 'contents' => [{'type' => 'EssenceText'}]}] }

          context 'that is having a definition' do
            before { allow(Element).to receive(:definitions).and_return(elements) }

            it "returns all essence layout view partial names for that element" do
              is_expected.to include('alchemy/essences/_essence_text_view')
            end
          end

          context 'that has no definition' do
            before { allow(Element).to receive(:definitions).and_return([]) }

            it "returns empty array" do
              is_expected.to be_empty
            end
          end
        end

        context 'with not an alchemy template given as name' do
          let(:name) { 'shop/cart' }

          it "calls rails template tracker" do
            expect(ActionView::DependencyTracker::ERBTracker).to receive(:call).with(name, nil)
            subject
          end
        end
      end
    end
  end
end
