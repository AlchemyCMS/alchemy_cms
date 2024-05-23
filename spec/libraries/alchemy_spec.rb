require "rails_helper"

RSpec.describe Alchemy do
  describe ".admin_importmaps" do
    subject { Alchemy.admin_importmaps }

    it "returns a Set of admin importmaps" do
      is_expected.to be_a(Set)
    end

    it "includes alchemy_admin importmap" do
      expect(subject.first).to eq({
        importmap_path: Alchemy::Engine.root.join("config/importmap.rb"),
        name: "alchemy_admin",
        source_paths: [
          Alchemy::Engine.root.join("app/javascript"),
          Alchemy::Engine.root.join("vendor/javascript")
        ]
      })
    end

    context "with additional importmaps" do
      before do
        Alchemy.admin_importmaps.add({
          importmap_path: Rails.root.join("config/importmap.rb"),
          name: "additional_importmap",
          source_paths: [Rails.root.join("app/javascript")]
        })
      end

      it "adds additional importmap to admin imports" do
        initializer = Alchemy::Engine.initializers.find { _1.name == "alchemy.importmap" }
        expect(Alchemy.admin_js_imports).to receive(:add).with("additional_importmap")
        initializer.run(Rails.application)
      end
    end
  end
end
