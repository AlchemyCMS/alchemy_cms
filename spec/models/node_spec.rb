require 'spec_helper'

module Alchemy
  describe Node do

    it "is only possible to create a node with name and language given" do
      expect { Node.create! }.to raise_error
      expect { Node.create!(name: 'Node', language: Language.default) }.to_not raise_error
    end

    # Class methods

    describe '.language_root_nodes' do
      context 'with no current language present' do
        before do
          expect(Language).to receive(:current).and_return(nil)
        end

        it "raises error if no current language is set" do
          expect { Node.language_root_nodes }.to raise_error
        end
      end

      context 'with current language present' do
        let(:root_node)  { create(:node) }
        let(:child_node) { create(:node, parent_id: root_node.id) }

        it "returns root nodes from curren language" do
          expect(Node.language_root_nodes).to include(root_node)
          expect(Node.language_root_nodes).to_not include(child_node)
        end
      end
    end

    # Instance methods

    describe '#url' do
      let(:page) { build_stubbed(:page) }

      context 'with navigatable attached' do
        let(:node) { build_stubbed(:node, navigatable: page) }

        it "gets the url from navigatable" do
          expect(node.url).to eq(page.urlname)
        end
      end

      context 'without navigatable attached' do
        let(:node) { build_stubbed(:node, url: 'http://google.com') }

        it "gets the url from url attribute" do
          expect(node.url).to eq('http://google.com')
        end
      end
    end

    describe '#root?' do
      context 'without parent' do
        let(:node) { build_stubbed(:node) }

        it "returns true" do
          expect(node.root?).to be_truthy
        end
      end

      context 'with parent' do
        let(:parent) { build_stubbed(:node) }
        let(:node)   { build_stubbed(:node, parent_id: parent.id) }

        it "returns false" do
          expect(node.root?).to be_falsey
        end
      end
    end

    # context 'folding' do
    #   let(:user) { mock_model('DummyUser') }

    #   describe '#fold!' do
    #     context "with folded status set to true" do
    #       it "should create a folded node for user" do
    #         node.fold!(user.id, true)
    #         expect(node.folded_nodes.first.user_id).to eq(user.id)
    #       end
    #     end
    #   end

    #   describe '#folded?' do
    #     let(:node) { Page.new }

    #     context 'with user is a active record model' do
    #       before do
    #         Alchemy.user_class.should_receive(:'<').and_return(true)
    #       end

    #       context 'if node is folded' do
    #         before do
    #           node.stub_chain(:folded_nodes, :where, :any?).and_return(true)
    #         end

    #         it "should return true" do
    #           expect(node.folded?(user.id)).to eq(true)
    #         end
    #       end

    #       context 'if node is not folded' do
    #         it "should return false" do
    #           expect(node.folded?(101093)).to eq(false)
    #         end
    #       end
    #     end
    #   end
    # end
  end
end
