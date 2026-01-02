# frozen_string_literal: true

require "rails_helper"
require "rails/generators"
require "generators/alchemy/ingredient/ingredient_generator"

RSpec.describe Alchemy::Generators::IngredientGenerator do
  let(:destination) { Rails.root.join("tmp/generators") }

  before do
    FileUtils.rm_rf(destination)
    FileUtils.mkdir_p(destination)
  end

  after do
    FileUtils.rm_rf(destination)
  end

  def run_generator(args = ["Color"])
    described_class.start(args, destination_root: destination, quiet: true)
  end

  describe "generating a custom ingredient" do
    before { run_generator(["Foo"]) }

    it "creates the model" do
      model_path = destination.join("app/models/alchemy/ingredients/foo.rb")
      expect(File.exist?(model_path)).to be true
      content = File.read(model_path)
      expect(content).to include("class Foo < Alchemy::Ingredient")
    end

    it "creates the view component" do
      view_path = destination.join("app/components/alchemy/ingredients/foo_view.rb")
      expect(File.exist?(view_path)).to be true
      content = File.read(view_path)
      expect(content).to include("class FooView < BaseView")
    end

    it "creates the editor component" do
      editor_path = destination.join("app/components/alchemy/ingredients/foo_editor.rb")
      expect(File.exist?(editor_path)).to be true
      content = File.read(editor_path)
      expect(content).to include("class FooEditor < BaseEditor")
    end

    it "does not create an editor partial" do
      partial_path = destination.join("app/views/alchemy/ingredients/_foo_editor.html.erb")
      expect(File.exist?(partial_path)).to be false
    end
  end

  describe "with underscored class name" do
    before { run_generator(["foo_bar"]) }

    it "creates properly named files" do
      expect(File.exist?(destination.join("app/models/alchemy/ingredients/foo_bar.rb"))).to be true
      expect(File.exist?(destination.join("app/components/alchemy/ingredients/foo_bar_view.rb"))).to be true
      expect(File.exist?(destination.join("app/components/alchemy/ingredients/foo_bar_editor.rb"))).to be true
    end

    it "uses classified name in class definitions" do
      model_content = File.read(destination.join("app/models/alchemy/ingredients/foo_bar.rb"))
      expect(model_content).to include("class FooBar < Alchemy::Ingredient")
    end
  end
end
