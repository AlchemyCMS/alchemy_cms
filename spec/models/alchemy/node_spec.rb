# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Node do
    it { is_expected.to have_many(:node_ingredients) }
    it { is_expected.to respond_to(:menu_type) }

    it "is only valid with language and name given" do
      expect(Node.new).to be_invalid
      expect(build(:alchemy_node)).to be_valid
    end

    describe ".language_root_nodes" do
      context "with no current language present" do
        before { expect(Current).to receive(:language) { nil } }

        it "raises error if no current language is set" do
          expect { Node.language_root_nodes }.to raise_error("No language found")
        end
      end

      context "with current language present" do
        let!(:root_node) { create(:alchemy_node) }
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
    context "if there are node ingredients present" do
      let(:node) { create(:alchemy_node) }
      let(:page) { create(:alchemy_page, :layoutpage, page_layout: :footer) }
      let(:element) { create(:alchemy_element, name: "menu", page_version: page.draft_version) }

      before do
        create(:alchemy_ingredient_node, element: element, related_object: node)
      end

      it "does not destroy the node but adds an error" do
        node.destroy
        expect(node).not_to be_destroyed
        expect(node.errors.full_messages).to eq(["This menu item is in use inside an Alchemy element on the following pages: #{page.name}."])
      end

      context "if there are node ingredients present on a child node" do
        let!(:parent_node) { create(:alchemy_node, children: [node]) }

        it "does not destroy the node and children either but adds an error" do
          parent_node.reload.destroy
          expect(parent_node).not_to be_destroyed
          expect(parent_node.errors.full_messages).to eq(["This menu item is in use inside an Alchemy element on the following pages: #{page.name}."])
        end
      end
    end

    describe ".all_from_clipboard" do
      let!(:node_1) { create(:alchemy_node) }
      let!(:node_2) { create(:alchemy_node) }
      let(:clipboard) { [{"id" => node_1.id.to_s}, {"id" => node_2.id.to_s}] }

      it "returns all nodes from clipboard" do
        expect(Node.all_from_clipboard(clipboard)).to contain_exactly(node_1, node_2)
      end

      context "with empty clipboard" do
        let(:clipboard) { [] }

        it "returns empty array" do
          expect(Node.all_from_clipboard(clipboard)).to eq([])
        end
      end

      context "with nil clipboard" do
        let(:clipboard) { nil }

        it "returns empty array" do
          expect(Node.all_from_clipboard(clipboard)).to eq([])
        end
      end
    end

    describe ".copy_and_paste" do
      let(:source) { create(:alchemy_node, name: "Source Node", url: "/source") }
      let(:new_parent) { create(:alchemy_node) }
      let(:node_name) { "Copied Node" }

      subject { Node.copy_and_paste(source, new_parent, node_name) }

      it "creates a copy of the source node with the given name under the new parent" do
        expect(subject.name).to eq(node_name)
        expect(subject.parent).to eq(new_parent)
        expect(subject.language).to eq(new_parent.language)
      end

      it "copies the source node attributes" do
        expect(subject.url).to eq(source.url)
        expect(subject.menu_type).to eq(source.menu_type)
      end

      it "returns the copied node" do
        expect(subject).to be_a(Alchemy::Node)
        expect(subject).to be_persisted
      end

      context "when source node has children" do
        let!(:child_node_1) { create(:alchemy_node, parent: source, name: "Child 1") }
        let!(:child_node_2) { create(:alchemy_node, parent: source, name: "Child 2") }

        it "also copies all descendant nodes" do
          expect(subject.children.length).to eq(2)
          expect(subject.children.map(&:name)).to contain_exactly("Child 1", "Child 2")
        end

        it "maintains the hierarchy structure" do
          copied_child = subject.children.first
          expect(copied_child.parent).to eq(subject)
          expect(copied_child.language).to eq(subject.language)
        end
      end

      context "with nested children" do
        let!(:child_node) { create(:alchemy_node, parent: source, name: "Child") }
        let!(:grandchild_node) { create(:alchemy_node, parent: child_node, name: "Grandchild") }

        it "copies the entire nested structure" do
          copied_child = subject.children.first
          copied_grandchild = copied_child.children.first

          expect(copied_grandchild.name).to eq("Grandchild")
          expect(copied_grandchild.parent).to eq(copied_child)
        end
      end

      context "when trying to paste node as child of itself" do
        let(:new_parent) { source }

        it "returns nil and does not create a copy" do
          expect(subject).to be_nil
          expect(Node.where(name: node_name)).to be_empty
        end
      end

      context "when trying to paste node as child of its descendant" do
        let!(:child_node) { create(:alchemy_node, parent: source, name: "Child") }
        let(:new_parent) { child_node }

        it "returns nil and does not create a copy" do
          source.reload # Refresh nested set values after creating children
          expect(subject).to be_nil
          expect(Node.where(name: node_name)).to be_empty
        end
      end

      context "when trying to paste node as child of its deep descendant" do
        let!(:child_node) { create(:alchemy_node, parent: source, name: "Child") }
        let!(:grandchild_node) { create(:alchemy_node, parent: child_node, name: "Grandchild") }
        let(:new_parent) { grandchild_node }

        it "returns nil and does not create a copy" do
          source.reload # Refresh nested set values after creating children
          expect(subject).to be_nil
          expect(Node.where(name: node_name)).to be_empty
        end
      end
    end
  end
end
