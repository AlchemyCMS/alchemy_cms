# frozen_string_literal: true

require "shoulda-matchers"

RSpec.shared_examples_for "an essence" do
  let(:element) { Alchemy::Element.new }
  let(:content) { Alchemy::Content.new(name: "foo") }
  let(:content_definition) { { "name" => "foo" } }

  describe "eager loading" do
    before do
      2.times { described_class.create! }
    end

    it "does not throw error if eager loaded" do
      expect {
        described_class.all.includes(:ingredient_association).to_a
      }.to_not raise_error
    end
  end

  it "touches the element after save" do
    element = FactoryBot.create(:alchemy_element)
    content = FactoryBot.create(:alchemy_content, element: element, essence: essence, essence_type: essence.class.name)

    element.update_column(:updated_at, 3.days.ago)
    content.essence.update(essence.ingredient_column.to_sym => ingredient_value)

    element.reload
    expect(element.updated_at).to be_within(3.seconds).of(Time.current)
  end

  it "should have correct partial path" do
    underscored_essence = essence.class.name.demodulize.underscore
    expect(essence.to_partial_path).to eq("alchemy/essences/#{underscored_essence}_view")
  end

  describe "#definition" do
    subject { essence.definition }

    context "without element" do
      it { is_expected.to eq({}) }
    end

    context "with element" do
      before do
        expect(essence).to receive(:element).at_least(:once).and_return(element)
      end

      context "but without content definitions" do
        it { is_expected.to eq({}) }
      end

      context "and content definitions" do
        before do
          allow(essence).to receive(:content).and_return(content)
        end

        context "containing the content name" do
          before do
            expect(element).to receive(:content_definitions).at_least(:once).and_return([content_definition])
          end

          it "returns the content definition" do
            is_expected.to eq(content_definition)
          end
        end

        context "not containing the content name" do
          before do
            expect(element).to receive(:content_definitions).at_least(:once).and_return([])
          end

          it { is_expected.to eq({}) }
        end
      end
    end
  end

  describe "#ingredient=" do
    it "should set the value to ingredient column" do
      essence.ingredient = ingredient_value
      expect(essence.ingredient).to eq ingredient_value
    end
  end

  describe "validations" do
    context "without essence definition in elements.yml" do
      it "should return an empty array" do
        allow(essence).to receive(:definition).and_return nil
        expect(essence.validations).to eq([])
      end
    end

    context "without validations defined in essence definition in elements.yml" do
      it "should return an empty array" do
        allow(essence).to receive(:definition).and_return({ name: "test", type: "EssenceText" })
        expect(essence.validations).to eq([])
      end
    end

    describe "presence" do
      context "with string given as validation type" do
        before do
          allow(essence).to receive(:definition).and_return({ "validate" => ["presence"] })
        end

        context "when the ingredient column is empty" do
          before do
            essence.update(essence.ingredient_column.to_sym => nil)
          end

          it "should not be valid" do
            expect(essence).to_not be_valid
          end
        end

        context "when the ingredient column is not nil" do
          before do
            essence.update(essence.ingredient_column.to_sym => ingredient_value)
          end

          it "should be valid" do
            expect(essence).to be_valid
          end
        end
      end

      context "with hash given as validation type" do
        context "where the value is true" do
          before do
            allow(essence).to receive(:definition).and_return({ "validate" => [{ "presence" => true }] })
          end

          context "when the ingredient column is empty" do
            before do
              essence.update(essence.ingredient_column.to_sym => nil)
            end

            it "should not be valid" do
              expect(essence).to_not be_valid
            end
          end

          context "when the ingredient column is not nil" do
            before do
              essence.update(essence.ingredient_column.to_sym => ingredient_value)
            end

            it "should be valid" do
              expect(essence).to be_valid
            end
          end
        end

        context "where the value is false" do
          before do
            allow(essence).to receive(:definition).and_return({ "validate" => [{ "presence" => false }] })
          end

          it "should be valid" do
            expect(essence).to be_valid
          end
        end
      end
    end

    describe "uniqueness" do
      before do
        allow(essence).to receive(:element).and_return(FactoryBot.create(:alchemy_element))
        essence.update(essence.ingredient_column.to_sym => ingredient_value)
      end

      context "with string given as validation type" do
        before do
          expect(essence).to receive(:definition).at_least(:once).and_return({ "validate" => ["uniqueness"] })
        end

        context "when a duplicate exists" do
          before do
            allow(essence).to receive(:duplicates).and_return([essence.dup])
          end

          it "should not be valid" do
            expect(essence).to_not be_valid
          end

          context "when validated essence is not public" do
            before do
              expect(essence).to receive(:public?).and_return(false)
            end

            it "should be valid" do
              expect(essence).to be_valid
            end
          end
        end

        context "when no duplicate exists" do
          before do
            expect(essence).to receive(:duplicates).and_return([])
          end

          it "should be valid" do
            expect(essence).to be_valid
          end
        end
      end

      context "with hash given as validation type" do
        context "where the value is true" do
          before do
            expect(essence).to receive(:definition).at_least(:once).and_return({ "validate" => [{ "uniqueness" => true }] })
          end

          context "when a duplicate exists" do
            before do
              allow(essence).to receive(:duplicates).and_return([essence.dup])
            end

            it "should not be valid" do
              expect(essence).to_not be_valid
            end

            context "when validated essence is not public" do
              before do
                expect(essence).to receive(:public?).and_return(false)
              end

              it "should be valid" do
                expect(essence).to be_valid
              end
            end
          end

          context "when no duplicate exists" do
            before do
              expect(essence).to receive(:duplicates).and_return([])
            end

            it "should be valid" do
              expect(essence).to be_valid
            end
          end
        end

        context "where the value is false" do
          before do
            allow(essence).to receive(:definition).and_return({ "validate" => [{ "uniqueness" => false }] })
          end

          it "should be valid" do
            expect(essence).to be_valid
          end
        end
      end
    end

    describe "#acts_as_essence?" do
      it "should return true" do
        expect(essence.acts_as_essence?).to be_truthy
      end
    end
  end

  context "delegations" do
    it { should delegate_method(:restricted?).to(:page) }
    it { should delegate_method(:public?).to(:element) }
  end

  describe "essence relations" do
    let(:page) { FactoryBot.create(:alchemy_page, :restricted) }
    let(:element) { FactoryBot.create(:alchemy_element) }

    it "registers itself on page as essence relation" do
      expect(page.respond_to?(essence.class.model_name.route_key)).to be(true)
    end

    it "registers itself on element as essence relation" do
      expect(element.respond_to?(essence.class.model_name.route_key)).to be(true)
    end
  end
end
