# encoding: utf-8
require 'spec_helper'
require 'rails/generators/alchemy/site_layouts/site_layouts_generator' # Generators are not automatically loaded by Rails

module Alchemy
  RSpec.describe Generators::SiteLayoutsGenerator, type: :generator do
    setup_default_destination

    let(:partial) { "app/views/alchemy/site_layouts/_blog" }

    before do
      create(:alchemy_site, name: "blog")
    end

    describe "the view partial" do
      describe 'generated with no flag' do
        before { run_generator }
        subject { file("#{partial}.html.erb") }

        it { is_expected.to exist }
        it { is_expected.to contain(/<%= yield %>/) }
      end

      describe 'generated with flag `--template_engine haml`' do
        before { run_generator %w(--template_engine haml) }
        subject { file("#{partial}.html.haml") }

        it { is_expected.to exist }
        it { is_expected.to contain(/= yield/) }
      end

      describe 'generated with flag `--template_engine slim`' do
        before { run_generator %w(--template_engine slim) }
        subject { file("#{partial}.html.slim") }

        it { is_expected.to exist }
        it { is_expected.to contain(/= yield/) }
      end
    end
  end
end
