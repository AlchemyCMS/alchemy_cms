RSpec.shared_examples_for "a relatable resource" do |args|
  it { is_expected.to have_many(:related_ingredients) }
  it { is_expected.to have_many(:elements).through(:related_ingredients) }
  it { is_expected.to have_many(:pages).through(:elements) }

  describe ".deletable" do
    let!(:assigned_resource) { create(:"alchemy_#{args[:resource_name]}") }
    let!(:unassigned_resource) { create(:"alchemy_#{args[:resource_name]}") }
    let!(:ingredient1) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object_type: described_class) }
    let!(:ingredient2) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object: assigned_resource) }

    it "should return all records that are not assigned to an ingredient" do
      expect(described_class.deletable).to eq [unassigned_resource]
    end
  end

  describe "#deletable?" do
    let(:resource) { create(:"alchemy_#{args[:resource_name]}") }

    context "if related to ingredient" do
      let!(:ingredient) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object: resource) }

      subject { resource.deletable? }

      it { is_expected.to be(false) }
    end

    context "if not related to ingredient" do
      subject { resource.deletable? }

      it { is_expected.to be(true) }
    end
  end
end
