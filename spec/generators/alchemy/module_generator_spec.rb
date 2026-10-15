# frozen_string_literal: true

require "rails_helper"
require "rails/generators"
require "active_support/testing/stream"
require "generators/alchemy/module/module_generator"

RSpec.describe Alchemy::Generators::ModuleGenerator do
  include ActiveSupport::Testing::Stream

  around do |example|
    Dir.mktmpdir do |dir|
      @destination = Pathname.new(dir)
      example.run
    end
  end

  let(:destination) { @destination }

  before do
    destination.join("config").mkpath
    destination.join("config/routes.rb").write("Rails.application.routes.draw do\nend\n")
    capture(:stdout) do
      described_class.start([module_name], destination_root: destination)
    end
  end

  let(:module_name) { "events" }
  let(:initializer) { destination.join("config/initializers/alchemy_#{module_name}.rb").read }

  it "adds the module to the menu configuration" do
    expect(initializer).to include("config.menu.add(")
    expect(initializer).to include("url: -> { main_app.admin_events_path }")
    expect(initializer).to include("condition: -> { can?(:index, :admin_events) }")
  end

  context "with an uncountable module name" do
    let(:module_name) { "news" }

    it "links to the index route" do
      expect(initializer).to include("url: -> { main_app.admin_news_index_path }")
      expect(initializer).to include("condition: -> { can?(:index, :admin_news) }")
    end
  end

  it "does not use the deprecated register_module" do
    expect(initializer).not_to include("register_module")
  end

  it "adds the ability to the abilities configuration" do
    expect(initializer).to include('config.abilities.add("EventsAbility")')
    expect(initializer).not_to include("register_ability")
    expect(initializer).not_to include("to_prepare")
  end

  it "generates valid Ruby" do
    expect { RubyVM::InstructionSequence.compile(initializer) }.not_to raise_error
  end
end
