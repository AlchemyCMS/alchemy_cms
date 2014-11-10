require 'spec_helper'

module Alchemy
  describe EssenceHtml do
    let (:essence) { EssenceHtml.new(source: '<p>hello!</p>') }

    it_behaves_like "an essence" do
      let(:essence)          { EssenceHtml.new }
      let(:ingredient_value) { '<p>hello!</p>' }
    end

    describe '#preview_text' do
      it "should return html escaped source code" do
        expect(essence.preview_text).to eq('&lt;p&gt;hello!&lt;/p&gt;')
      end
    end
  end
end
