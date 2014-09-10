require 'spec_helper'

module Alchemy
  describe Admin::NodesController do
    let(:user) { editor_user }

    before { sign_in(user) }

    describe '#index' do
      let!(:root_node)  { Node.root }
      let!(:child_node) { create(:node, parent_id: root_node.id) }

      it "loads only root nodes from current language" do
        get :index
        expect(assigns('nodes').to_a).to eq([root_node])
        expect(assigns('nodes').to_a).to_not eq([child_node])
      end
    end

    describe '#new' do
      it "sets the current language" do
        get :new
        expect(assigns('node').language).to eq(Language.current)
      end

      context 'with parent id in params' do
        it "sets it to node" do
          get :new, parent_id: 1
          expect(assigns('node').parent_id).to eq(1)
        end
      end
    end

    describe '#create' do
      context 'with valid params' do
        it "redirects to nodes path" do
          post :create, node: {name: 'Node', language_id: Language.current.id}
          expect(response).to redirect_to(admin_nodes_path)
        end
      end
    end

    describe '#update' do
      let(:node) { create(:node) }

      context 'with valid params' do
        it "redirects to nodes path" do
          put :update, id: node.id, node: {name: 'Node'}
          expect(response).to redirect_to(admin_nodes_path)
        end
      end
    end

    # describe '#fold' do
    #   let(:page) { mock_model(Alchemy::Page) }
    #   before { Page.stub(:find).and_return(page) }

    #   context "if page is currently not folded" do
    #     before { page.stub(:folded?).and_return(false) }

    #     it "should fold the page" do
    #       page.should_receive(:fold!).with(user.id, true).and_return(true)
    #       xhr :post, :fold, id: page.id
    #     end
    #   end

    #   context "if page is already folded" do
    #     before { page.stub(:folded?).and_return(true) }

    #     it "should unfold the page" do
    #       page.should_receive(:fold!).with(user.id, false).and_return(true)
    #       xhr :post, :fold, id: page.id
    #     end
    #   end
    # end

    # describe '#sort' do
    #   before { Page.stub(:language_root_for).and_return(mock_model(Alchemy::Page)) }

    #   it "should assign @sorting with true" do
    #     xhr :get, :sort
    #     expect(assigns(:sorting)).to eq(true)
    #   end
    # end

    # describe '#order' do
    #   let(:page_1)       { create(:page, visible: true) }
    #   let(:page_2)       { create(:page, visible: true) }
    #   let(:page_3)       { create(:page, visible: true) }
    #   let(:page_item_1)  { {id: page_1.id, slug: page_1.slug, restricted: false, external: page_1.redirects_to_external?, visible: page_1.visible?, children: [page_item_2]} }
    #   let(:page_item_2)  { {id: page_2.id, slug: page_2.slug, restricted: false, external: page_2.redirects_to_external?, visible: page_2.visible?, children: [page_item_3]} }
    #   let(:page_item_3)  { {id: page_3.id, slug: page_3.slug, restricted: false, external: page_3.redirects_to_external?, visible: page_3.visible? } }
    #   let(:set_of_pages) { [page_item_1] }

    #   it "stores the new order" do
    #     xhr :post, :order, set: set_of_pages.to_json
    #     page_1.reload
    #     expect(page_1.descendants).to eq([page_2, page_3])
    #   end

    #   context 'with url nesting enabled' do
    #     before { Config.stub(get: true) }

    #     it "updates the pages urlnames" do
    #       xhr :post, :order, set: set_of_pages.to_json
    #       [page_1, page_2, page_3].map(&:reload)
    #       expect(page_1.urlname).to eq("#{page_1.slug}")
    #       expect(page_2.urlname).to eq("#{page_1.slug}/#{page_2.slug}")
    #       expect(page_3.urlname).to eq("#{page_1.slug}/#{page_2.slug}/#{page_3.slug}")
    #     end

    #     context 'with invisible page in tree' do
    #       let(:page_item_2) do
    #         {
    #           id: page_2.id,
    #           slug: page_2.slug,
    #           children: [page_item_3],
    #           visible: false
    #         }
    #       end

    #       it "does not use this pages slug in urlnames of descendants" do
    #         xhr :post, :order, set: set_of_pages.to_json
    #         [page_1, page_2, page_3].map(&:reload)
    #         expect(page_1.urlname).to eq("#{page_1.slug}")
    #         expect(page_2.urlname).to eq("#{page_1.slug}/#{page_2.slug}")
    #         expect(page_3.urlname).to eq("#{page_1.slug}/#{page_3.slug}")
    #       end
    #     end

    #     context 'with external page in tree' do
    #       let(:page_item_2) do
    #         {
    #           id: page_2.id,
    #           slug: page_2.slug,
    #           children: [page_item_3],
    #           external: true
    #         }
    #       end

    #       it "does not use this pages slug in urlnames of descendants" do
    #         xhr :post, :order, set: set_of_pages.to_json
    #         [page_1, page_2, page_3].map(&:reload)
    #         expect(page_3.urlname).to eq("#{page_1.slug}/#{page_3.slug}")
    #       end
    #     end

    #     context 'with restricted page in tree' do
    #       let(:page_2) { create(:page, restricted: true) }
    #       let(:page_item_2) do
    #         {
    #           id: page_2.id,
    #           slug: page_2.slug,
    #           children: [page_item_3],
    #           restricted: true
    #         }
    #       end

    #       it "updates restricted status of descendants" do
    #         xhr :post, :order, set: set_of_pages.to_json
    #         page_3.reload
    #         expect(page_3.restricted).to be_true
    #       end
    #     end

    #     context 'with page having number as slug' do
    #       let(:page_item_2) do
    #         {
    #           id: page_2.id,
    #           slug: 42,
    #           children: [page_item_3]
    #         }
    #       end

    #       it "does not raise error" do
    #         expect {
    #           xhr :post, :order, set: set_of_pages.to_json
    #         }.to_not raise_error(TypeError)
    #         [page_1, page_2, page_3].map(&:reload)
    #         expect(page_3.urlname).to eq("#{page_1.slug}/#{page_2.slug}/#{page_3.slug}")
    #       end
    #     end

    #     it "creates legacy urls" do
    #       xhr :post, :order, set: set_of_pages.to_json
    #       [page_2, page_3].map(&:reload)
    #       expect(page_2.legacy_urls.size).to eq(1)
    #       expect(page_3.legacy_urls.size).to eq(1)
    #     end
    #   end
    # end
  end
end