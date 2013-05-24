require 'spec_helper'

module Alchemy
  describe EssenceHtml do
    describe '#preview_text' do
      let (:essence_html) { EssenceHtml.new(source: '<p>hello!</p>') }

      it "should return html escaped source code" do
        expect(essence_html.preview_text).to eq('&lt;p&gt;hello!&lt;/p&gt;')
      end
    end
  end
end
