# encoding: utf-8
require 'spec_helper'
require 'rails/generators/alchemy/page_layouts/page_layouts_generator' # Generators are not automatically loaded by Rails

module Alchemy
  RSpec.describe Generators::PageLayoutsGenerator, type: :generator do
    setup_default_destination

    let(:partial) { "app/views/alchemy/page_layouts/_everything" }

    describe "the view partial" do
      describe "generated with no flag" do
        before { run_generator }
        subject { file("#{partial}.html.erb") }
        it { is_expected.to exist }
        it { is_expected.to contain(/<%= render_elements %>/) }
      end

      describe "generated with flag `--template_engine haml`" do
        before { run_generator %w(--template_engine haml) }
        subject { file("#{partial}.html.haml") }
        it { is_expected.to exist }
        it { is_expected.to contain(/= render_elements/) }
      end

      describe "generated with flag `--template_engine slim`" do
        before { run_generator %w(--template_engine slim) }
        subject { file("#{partial}.html.slim") }
        it { is_expected.to exist }
        it { is_expected.to contain(/= render_elements/) }
      end
    end
  end
end
