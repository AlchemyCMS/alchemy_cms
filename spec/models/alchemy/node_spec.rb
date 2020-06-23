# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Node do
    it { is_expected.to have_many(:essence_nodes) }
    it { is_expected.to respond_to(:menu_type) }

    it "is only valid with language and name given" do
      expect(Node.new).to be_invalid
      expect(build(:alchemy_node)).to be_valid
    end

    describe ".language_root_nodes" do
      context "with no current language present" do
        before { expect(Language).to receive(:current) { nil } }

        it "raises error if no current language is set" do
          expect { Node.language_root_nodes }.to raise_error("No language found")
        end
      end

      context "with current language present" do
        let!(:root_node)  { create(:alchemy_node) }
        let!(:child_node) { create(:alchemy_node, parent_id: root_node.id) }

        it "returns root nodes from current language" do
          expect(Node.language_root_nodes).to include(root_node)
          expect(Node.language_root_nodes).to_not include(child_node)
        end
      end
    end

    describe ".available_menu_names" do
      subject { described_class.available_menu_names }

      it { is_expected.to contain_exactly("main_menu", "footer_menu") }
    end

    describe "#url" do
      it "is valid with leading slash" do
        expect(build(:alchemy_node, url: "/something")).to be_valid
      end

      it "is invalid without leading slash" do
        expect(build(:alchemy_node, url: "something")).to be_invalid
      end

      it "is valid with leading protocol scheme" do
        expect(build(:alchemy_node, url: "i2+ts-z.app:widget.io")).to be_valid
      end

      context "with page attached" do
        let(:node) { create(:alchemy_node, :with_page) }

        it "returns the url from page" do
          expect(node.url).to eq("/#{node.page.urlname}")
        end

        context "and with url set" do
          let(:node) { build(:alchemy_node, :with_page, url: "http://google.com") }

          it "still returns the url from the page" do
            expect(node.url).to eq("/#{node.page.urlname}")
          end
        end
      end

      context "without page attached" do
        let(:node) { build(:alchemy_node, url: "http://google.com") }

        it "returns the url from url attribute" do
          expect(node.url).to eq("http://google.com")
        end

        context "and without url set" do
          let(:node) { build(:alchemy_node) }

          it do
            expect(node.url).to be_nil
          end
        end
      end
    end

    describe "#name" do
      subject { node.name }

      let(:parent) { build_stubbed(:alchemy_node) }
      context "with page attached" do
        let(:node) { build_stubbed(:alchemy_node, :with_page, parent: parent) }

        it "returns the name from page" do
          expect(node.name).to eq(node.page.name)
        end

        context "but with name set" do
          let(:node) { build_stubbed(:alchemy_node, :with_page, name: "Google", parent: parent) }

          it "still returns the name from name attribute" do
            expect(node.name).to eq("Google")
          end
        end
      end

      context "without page attached" do
        let(:node) { build_stubbed(:alchemy_node, name: "Google") }

        it "returns the name from name attribute" do
          expect(node.name).to eq("Google")
        end
      end
    end

    describe "#to_partial_path" do
      let(:node) { build(:alchemy_node, name: "Main Menu") }

      it "returns the path to the menu wrapper partial" do
        expect(node.to_partial_path).to eq("alchemy/menus/main_menu/node")
      end
    end
  end

  describe "#destroy" do
    context "if there are essence nodes present" do
      let(:node) { create(:alchemy_node) }
      let(:page) { create(:alchemy_page, :layoutpage, page_layout: :footer) }
      let(:element) { create(:alchemy_element, name: "menu", page: page) }
      let(:content) { create(:alchemy_content, name: "menu", element: element) }

      before do
        node.essence_nodes.create(content: content)
      end

      it "does not destroy the node but adds an error" do
        node.destroy
        expect(node).not_to be_destroyed
        expect(node.errors.full_messages).to eq(["This menu item is in use inside an Alchemy element on the following pages: #{page.name}."])
      end

      context "if there are essence nodes present on a child node" do
        let!(:parent_node) { create(:alchemy_node, children: [node]) }

        it "does not destroy the node and children either but adds an error" do
          parent_node.reload.destroy
          expect(parent_node).not_to be_destroyed
          expect(parent_node.errors.full_messages).to eq(["This menu item is in use inside an Alchemy element on the following pages: #{page.name}."])
        end
      end
    end
  end
end
