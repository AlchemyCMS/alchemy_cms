# encoding: utf-8
require 'spec_helper'
require 'rails/generators/alchemy/elements/elements_generator' # Generators are not automatically loaded by Rails

module Alchemy
  RSpec.describe Generators::ElementsGenerator, type: :generator do
    setup_default_destination

    describe "the view partial" do
      let(:partial) { "app/views/alchemy/elements/_all_you_can_eat_view" }

      describe "generated with no flag" do
        before { run_generator }
        subject { file("#{partial}.html.erb") }

        it { is_expected.to exist }
        it { is_expected.to contain(/<%- cache\(element\) do -%>/) }
        it { is_expected.to contain(/<%= element_view_for\(element\) do |el| %>/) }
        it { is_expected.to contain(/<%= el.render :essence_text %>/) }
        it { is_expected.to contain(/<%= el.render :essence_picture %>/) }
        it { is_expected.to contain(/<%= el.render :essence_richtext %>/) }
        it { is_expected.to contain(/<%= el.render :essence_select %>/) }
        it { is_expected.to contain(/<%= el.render :essence_boolean %>/) }
        it { is_expected.to contain(/<%= el.render :essence_date %>/) }
        it { is_expected.to contain(/<%= el.render :essence_file %>/) }
        it { is_expected.to contain(/<%= el.render :essence_html %>/) }
        it { is_expected.to contain(/<%= el.render :essence_link %>/) }
      end

      describe "generated with flag `--template_engine haml`" do
        before { run_generator %w(--template_engine haml) }
        subject { file("#{partial}.html.haml") }

        it { is_expected.to exist }
        it { is_expected.to contain(/- cache\(element\) do/) }
        it { is_expected.to contain(/= element_view_for\(element\) do |el|/) }
        it { is_expected.to contain(/= el.render :essence_text/) }
        it { is_expected.to contain(/= el.render :essence_picture/) }
        it { is_expected.to contain(/= el.render :essence_richtext/) }
        it { is_expected.to contain(/= el.render :essence_select/) }
        it { is_expected.to contain(/= el.render :essence_boolean/) }
        it { is_expected.to contain(/= el.render :essence_date/) }
        it { is_expected.to contain(/= el.render :essence_file/) }
        it { is_expected.to contain(/= el.render :essence_html/) }
        it { is_expected.to contain(/= el.render :essence_link/) }
      end

      describe "generated with flag `--template_engine slim`" do
        before { run_generator %w(--template_engine slim) }
        subject { file("#{partial}.html.slim") }

        it { is_expected.to exist }
        it { is_expected.to contain(/- cache\(element\) do/) }
        it { is_expected.to contain(/= element_view_for\(element\) do |el|/) }
        it { is_expected.to contain(/= el.render :essence_text/) }
        it { is_expected.to contain(/= el.render :essence_picture/) }
        it { is_expected.to contain(/= el.render :essence_richtext/) }
        it { is_expected.to contain(/= el.render :essence_select/) }
        it { is_expected.to contain(/= el.render :essence_boolean/) }
        it { is_expected.to contain(/= el.render :essence_date/) }
        it { is_expected.to contain(/= el.render :essence_file/) }
        it { is_expected.to contain(/= el.render :essence_html/) }
        it { is_expected.to contain(/= el.render :essence_link/) }
      end
    end

    describe "the editor partial" do
      let(:partial) { "app/views/alchemy/elements/_all_you_can_eat_editor" }

      describe "generated with no flag" do
        before { run_generator }
        subject { file("#{partial}.html.erb") }

        it { is_expected.to exist }
        it { is_expected.to contain(/<%- element_editor_for\(element\) do |el| %>/) }
        it { is_expected.to contain(/<%= el.edit :essence_text %>/) }
        it { is_expected.to contain(/<%= el.edit :essence_picture %>/) }
        it { is_expected.to contain(/<%= el.edit :essence_richtext %>/) }
        it { is_expected.to contain(/<%= el.edit :essence_select %>/) }
        it { is_expected.to contain(/<%= el.edit :essence_boolean %>/) }
        it { is_expected.to contain(/<%= el.edit :essence_date %>/) }
        it { is_expected.to contain(/<%= el.edit :essence_file %>/) }
        it { is_expected.to contain(/<%= el.edit :essence_html %>/) }
        it { is_expected.to contain(/<%= el.edit :essence_link %>/) }
      end

      describe "generated with flag `--template_engine haml`" do
        before { run_generator %w(--template_engine haml) }
        subject { file("#{partial}.html.haml") }

        it { is_expected.to exist }
        it { is_expected.to contain(/- element_editor_for\(element\) do |el|/) }
        it { is_expected.to contain(/= el.edit :essence_text/) }
        it { is_expected.to contain(/= el.edit :essence_picture/) }
        it { is_expected.to contain(/= el.edit :essence_richtext/) }
        it { is_expected.to contain(/= el.edit :essence_select/) }
        it { is_expected.to contain(/= el.edit :essence_boolean/) }
        it { is_expected.to contain(/= el.edit :essence_date/) }
        it { is_expected.to contain(/= el.edit :essence_file/) }
        it { is_expected.to contain(/= el.edit :essence_html/) }
        it { is_expected.to contain(/= el.edit :essence_link/) }
      end

      describe "generated with flag `--template_engine slim`" do
        before { run_generator %w(--template_engine slim) }
        subject { file("#{partial}.html.slim") }

        it { is_expected.to exist }
        it { is_expected.to contain(/- element_editor_for\(element\) do |el|/) }
        it { is_expected.to contain(/= el.edit :essence_text/) }
        it { is_expected.to contain(/= el.edit :essence_picture/) }
        it { is_expected.to contain(/= el.edit :essence_richtext/) }
        it { is_expected.to contain(/= el.edit :essence_select/) }
        it { is_expected.to contain(/= el.edit :essence_boolean/) }
        it { is_expected.to contain(/= el.edit :essence_date/) }
        it { is_expected.to contain(/= el.edit :essence_file/) }
        it { is_expected.to contain(/= el.edit :essence_html/) }
        it { is_expected.to contain(/= el.edit :essence_link/) }
      end
    end
  end
end
