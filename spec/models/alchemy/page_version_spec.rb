require 'spec_helper'

module Alchemy
  RSpec.describe PageVersion do
    let!(:page) { create(:alchemy_page, do_not_autogenerate: false) }
    let!(:page_version) { page.current_version }

    describe '#destroy' do
      it 'destroys all elements' do
        page_version.destroy
        expect(page_version.elements).to be_empty
      end

      context "with trashed but still assigned elements" do
        before do
          page_version.elements.map(&:trash!)
        end

        it "should not delete the trashed elements" do
          page_version.destroy
          expect(Element.trashed).not_to be_empty
        end
      end
    end
  end
end
