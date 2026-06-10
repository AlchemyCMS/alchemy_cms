RSpec.shared_examples_for "a relatable resource" do |args|
  it { is_expected.to have_many(:related_ingredients) }
  it { is_expected.to have_many(:related_elements).through(:related_ingredients) }
  it { is_expected.to have_many(:related_pages).through(:related_elements) }

  describe ".deletable" do
    subject { described_class.deletable }

    let!(:assigned_resource) { create(:"alchemy_#{args[:resource_name]}") }
    let!(:unassigned_resource) { create(:"alchemy_#{args[:resource_name]}") }
    let!(:ingredient1) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object: assigned_resource) }
    let!(:ingredient2) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object: nil) }

    it "should return all records that are not assigned to an ingredient" do
      is_expected.to eq [unassigned_resource]
    end
  end

  describe "#related_ingredients" do
    subject { resource.related_ingredients }

    context "with other related resources with same id" do
      let!(:resource) { create(:"alchemy_#{args[:resource_name]}") }
      let!(:ingredient1) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object: resource) }
      let!(:ingredient2) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object_type: "Event", related_object_id: resource.id) }

      it "are not included" do
        is_expected.to eq [ingredient1]
      end
    end

    context "with other related resources with same type" do
      let!(:resource) { create(:"alchemy_#{args[:resource_name]}") }
      let!(:ingredient1) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object: resource) }
      let!(:ingredient2) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object_type: described_class) }

      it "are not included" do
        is_expected.to eq [ingredient1]
      end
    end
  end

  describe "#deletable?" do
    let(:resource) { create(:"alchemy_#{args[:resource_name]}") }

    subject { resource.deletable? }

    context "if related to ingredient" do
      let!(:ingredient) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object: resource) }

      it { is_expected.to be(false) }
    end

    context "if not related to ingredient" do
      it { is_expected.to be(true) }
    end
  end

  describe "after_touch" do
    let(:related_object) { create(:"alchemy_#{args[:resource_name]}") }

    context "when related ingredients exist" do
      let!(:ingredient) { create(:"alchemy_ingredient_#{args[:ingredient_type]}", related_object:) }

      it "enqueues InvalidateElementsCacheJob" do
        expect {
          related_object.touch
        }.to have_enqueued_job(Alchemy::InvalidateElementsCacheJob).with(described_class.name, related_object.id)
      end
    end

    context "when no related ingredients exist" do
      it "does not enqueue InvalidateElementsCacheJob" do
        expect { related_object.touch }.to_not have_enqueued_job(Alchemy::InvalidateElementsCacheJob)
      end
    end
  end
end
