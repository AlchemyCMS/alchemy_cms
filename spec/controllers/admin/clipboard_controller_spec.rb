require 'spec_helper'

module Alchemy
  describe Admin::ClipboardController do
    let(:public_page)     { build_stubbed(:public_page) }
    let(:element)         { build_stubbed(:element, page: public_page) }
    let(:another_element) { build_stubbed(:element, page: public_page) }

    before do
      sign_in(admin_user)
      session[:alchemy_clipboard] = {}
      Element.stub(find: element)
    end

    describe "#insert" do
      it "should hold element ids" do
        xhr :post, :insert, {remarkable_type: 'elements', remarkable_id: element.id}
        session[:alchemy_clipboard]['elements'].should == [{'id' => element.id.to_s, 'action' => 'copy'}]
      end

      it "should not have the same element twice" do
        session[:alchemy_clipboard]['elements'] = [{'id' => element.id.to_s, 'action' => 'copy'}]
        xhr :post, :insert, {remarkable_type: 'elements', remarkable_id: element.id}
        session[:alchemy_clipboard]['elements'].collect { |e| e['id'] }.should_not == [element.id, element.id]
      end
    end

    describe "#delete" do
      it "should remove element ids from clipboard" do
        session[:alchemy_clipboard]['elements'] = [{'id' => element.id.to_s, 'action' => 'copy'}]
        session[:alchemy_clipboard]['elements'] << {'id' => another_element.id.to_s, 'action' => 'copy'}
        xhr :delete, :remove, {remarkable_type: 'elements', remarkable_id: another_element.id}
        session[:alchemy_clipboard]['elements'].should == [{'id' => element.id.to_s, 'action' => 'copy'}]
      end
    end

    describe "#clear" do
      context "with elements as remarkable_type" do
        it "should clear the elements clipboard" do
          session[:alchemy_clipboard]['elements'] = [{'id' => element.id.to_s}]
          xhr :delete, :clear, {remarkable_type: 'elements'}
          session[:alchemy_clipboard]['elements'].should be_empty
        end
      end

      context "with pages as remarkable_type" do
        it "should clear the pages clipboard" do
          session[:alchemy_clipboard]['pages'] = [{'id' => public_page.id.to_s}]
          xhr :delete, :clear, {remarkable_type: 'pages'}
          session[:alchemy_clipboard]['pages'].should be_empty
        end
      end
    end
  end
end
