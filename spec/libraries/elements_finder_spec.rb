# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementsFinder do
  let(:finder) { described_class.new(options) }
  let(:options) { {} }

  describe "#elements" do
    subject { finder.elements }

    let(:page) { create(:alchemy_page, :public) }
    let!(:visible_element) { create(:alchemy_element, public: true, page: page) }
    let!(:hidden_element) { create(:alchemy_element, public: false, page: page) }

    context "without page given" do
      it do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "with page object given" do
      subject { finder.elements(page: page) }

      it "returns all public elements from page" do
        is_expected.to eq([visible_element])
      end

      it "does not return trashed elements" do
        visible_element.remove_from_list
        is_expected.to eq([])
      end

      context "with multiple ordered elements" do
        let!(:element_2) do
          create(:alchemy_element, public: true, page: page).tap { |el| el.update_columns(position: 3) }
        end

        let!(:element_3) do
          create(:alchemy_element, public: true, page: page).tap { |el| el.update_columns(position: 2) }
        end

        it "returns elements ordered by position" do
          is_expected.to eq([visible_element, element_3, element_2])
        end
      end

      context "with fixed elements present" do
        let!(:fixed_element) { create(:alchemy_element, :fixed, page: page) }

        it "does not include fixed elements" do
          is_expected.to_not include(fixed_element)
        end

        context "with options[:fixed] set to true" do
          let(:options) do
            { fixed: true }
          end

          it "includes only fixed elements" do
            is_expected.to eq([fixed_element])
          end
        end
      end

      context "with nested elements present" do
        let!(:nested_element) { create(:alchemy_element, :nested, page: page) }

        it "does not include nested elements" do
          is_expected.to_not include(nested_element)
        end
      end

      context "with options[:only] given" do
        let(:options) do
          { only: "article" }
        end

        it "returns only the elements with that name" do
          is_expected.to eq([visible_element])
        end
      end

      context "with options[:except] given" do
        let(:options) do
          { except: "article" }
        end

        it "does not return the elements with that name" do
          is_expected.to eq([])
        end
      end

      context "with options[:offset] given" do
        let(:options) do
          { offset: 2 }
        end

        let!(:visible_element_2) { create(:alchemy_element, public: true, page: page) }
        let!(:visible_element_3) { create(:alchemy_element, public: true, page: page) }

        it "returns elements beginning from that offset" do
          is_expected.to eq([visible_element_3])
        end
      end

      context "with options[:count] given" do
        let(:options) do
          { count: 1 }
        end

        let!(:visible_element_2) { create(:alchemy_element, public: true, page: page) }

        it "returns elements beginning from that offset" do
          is_expected.to eq([visible_element])
        end
      end

      context "with options[:reverse] given" do
        let(:options) do
          { reverse: true }
        end

        let!(:visible_element_2) { create(:alchemy_element, public: true, page: page) }

        it "returns elements in reverse order" do
          is_expected.to eq([visible_element_2, visible_element])
        end
      end

      context "with options[:random] given" do
        let(:options) do
          { random: true }
        end

        let(:random_function) do
          case ActiveRecord::Base.connection_config[:adapter]
          when "postgresql", "sqlite3"
            "RANDOM()"
          else
            "RAND()"
          end
        end

        it "returns elements in random order" do
          expect_any_instance_of(ActiveRecord::Relation).to \
            receive(:reorder).with(random_function).and_call_original
          subject
        end
      end
    end

    context "with page layout name given as options[:from_page]" do
      subject { finder.elements(page: "standard") }

      let(:page) { create(:alchemy_page, :public, page_layout: "standard") }
      let!(:visible_element) { create(:alchemy_element, public: true, page: page) }
      let!(:hidden_element) { create(:alchemy_element, public: false, page: page) }

      it "returns all public elements from page with given page layout" do
        is_expected.to eq([visible_element])
      end

      context "that is not found" do
        subject { finder.elements(page: "foobaz") }

        it "returns empty active record relation" do
          is_expected.to eq(Alchemy::Element.none)
        end
      end
    end

    context "with fallback options given" do
      subject { finder.elements(page: page) }

      let(:options) do
        {
          fallback: {
            for: "download",
            from: page_2,
          },
        }
      end

      context "and no element from that kind on current page" do
        let(:page) { create(:alchemy_page, :public, page_layout: "standard") }

        context "but element of that kind on fallback page" do
          let(:page_2) { create(:alchemy_page, :public, page_layout: "standard") }
          let!(:visible_element_2) { create(:alchemy_element, name: "download", public: true, page: page_2) }

          it "loads elements from fallback page" do
            is_expected.to eq([visible_element_2])
          end
        end

        context "with fallback element defined" do
          let(:options) do
            {
              fallback: {
                for: "download",
                with: "header",
                from: page_2,
              },
            }
          end

          let(:page_2) { create(:alchemy_page, :public, page_layout: "standard") }
          let!(:visible_element_2) { create(:alchemy_element, name: "header", public: true, page: page_2) }

          it "loads fallback element from fallback page" do
            is_expected.to eq([visible_element_2])
          end
        end

        context "with fallback page defined as pagelayout name" do
          let(:options) do
            {
              fallback: {
                for: "download",
                with: "text",
                from: "everything",
              },
            }
          end

          let(:page_2) { create(:alchemy_page, :public, page_layout: "everything") }
          let!(:visible_element_2) { create(:alchemy_element, name: "text", public: true, page: page_2) }

          it "loads fallback element from fallback page" do
            is_expected.to eq([visible_element_2])
          end
        end
      end
    end
  end
end
