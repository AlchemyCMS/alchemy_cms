# frozen_string_literal: true

require "rails_helper"
require "alchemy/configuration/class_set_option"

module ClassSetTest
  ClassA = Class.new
  ClassB = Class.new

  def self.reload
    [:ClassA, :ClassB].each do |klass|
      remove_const(klass)
      const_set(klass, Class.new)
    end
  end
end

RSpec.describe Alchemy::Configuration::ClassSetOption do
  let(:set) { described_class.new(value: [], name: :my_class_set) }

  describe "#concat" do
    it "can add one item" do
      set.concat(["ClassSetTest::ClassA"])
      expect(set).to include(ClassSetTest::ClassA)
    end

    it "can add two items" do
      set.concat(["ClassSetTest::ClassA", ClassSetTest::ClassB])
      expect(set).to include(ClassSetTest::ClassA)
      expect(set).to include(ClassSetTest::ClassB)
    end

    it "returns itself" do
      expect(set.concat(["String"])).to eql(set)
    end
  end

  describe "initializing with a default" do
    let(:set) { described_class.new(value: ["ClassSetTest::ClassA"], name: :my_class_set) }

    it "contains the default" do
      expect(set).to include(ClassSetTest::ClassA)
    end
  end

  describe "<<" do
    it "can add by string" do
      set << "ClassSetTest::ClassA"
      expect(set).to include(ClassSetTest::ClassA)
    end

    it "can add by class" do
      set << ClassSetTest::ClassA
      expect(set).to include(ClassSetTest::ClassA)
    end

    describe "class redefinition" do
      shared_examples "working code reloading" do
        it "works with a class" do
          original = ClassSetTest::ClassA

          ClassSetTest.reload

          # Sanity check
          expect(original).not_to eq(ClassSetTest::ClassA)

          expect(set).to include(ClassSetTest::ClassA)
          expect(set).to_not include(original)
        end
      end

      context "with a class" do
        before { set << ClassSetTest::ClassA }
        it_should_behave_like "working code reloading"
      end

      context "with a string" do
        before { set << "ClassSetTest::ClassA" }
        it_should_behave_like "working code reloading"
      end
    end
  end

  describe "#delete" do
    before do
      set << ClassSetTest::ClassA
    end

    it "can delete by string" do
      set.delete "ClassSetTest::ClassA"
      expect(set).not_to include(ClassSetTest::ClassA)
    end

    it "can delete by class" do
      set.delete ClassSetTest::ClassA
      expect(set).not_to include(ClassSetTest::ClassA)
    end
  end
end
