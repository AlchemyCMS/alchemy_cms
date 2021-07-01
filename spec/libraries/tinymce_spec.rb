# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Tinymce do
    describe ".init" do
      subject { Tinymce.init }

      it "returns the default config" do
        is_expected.to eq(Tinymce.class_variable_get("@@init"))
      end
    end

    describe ".init=" do
      let(:another_config) { { theme_advanced_buttons3: "table" } }

      it "merges the default config with given config" do
        Tinymce.init = another_config
        expect(Tinymce.init).to include(another_config)
      end
    end

    context "Methods for contents with custom tinymce config." do
      let(:content_definition) do
        {
          "name" => "text",
          "settings" => {
            "tinymce" => {
              "foo" => "bar",
            },
          },
        }
      end

      let(:element_definition) do
        {
          "name" => "article",
          "contents" => [content_definition],
        }
      end

      describe ".custom_config_contents" do
        let(:page) { build_stubbed(:alchemy_page) }

        let(:element_definitions) do
          [element_definition]
        end

        subject { Tinymce.custom_config_contents(page) }

        before do
          expect(page).to receive(:descendent_element_definitions) { element_definitions }
        end

        it "returns an array of content definitions that contain custom tinymce config
        and element name" do
          is_expected.to be_an(Array)
          is_expected.to include({
            "element" => element_definition["name"],
          }.merge(content_definition))
        end

        context "with no contents having custom tinymce config" do
          let(:content_definition) do
            { "name" => "text" }
          end

          it { is_expected.to eq([]) }
        end

        context "with element definition having nil as contents value" do
          let(:element_definition) do
            {
              "name" => "element",
              "contents" => nil,
            }
          end

          it "returns empty array" do
            is_expected.to eq([])
          end
        end

        context "with content settings tinymce set to true only" do
          let(:element_definition) do
            {
              "name" => "element",
              "contents" => [
                "name" => "headline",
                "settings" => {
                  "tinymce" => true,
                },
              ],
            }
          end

          it "returns empty array" do
            is_expected.to eq([])
          end
        end

        context "with nestable_elements defined" do
          let(:element_definitions) do
            [
              element_definition,
              {
                "name" => "nested_element",
                "contents" => [content_definition],
              },
            ]
          end

          it "includes these configs" do
            is_expected.to include({
              "element" => element_definition["name"],
            }.merge(content_definition))
          end
        end
      end

      describe ".custom_config_ingredients" do
        let(:page) { build_stubbed(:alchemy_page) }

        let(:element_definition) do
          {
            "name" => "article",
            "ingredients" => [ingredient_definition],
          }
        end

        let(:element_definitions) do
          [element_definition]
        end

        let(:ingredient_definition) do
          {
            "role" => "text",
            "settings" => {
              "tinymce" => {
                "foo" => "bar",
              },
            },
          }
        end

        subject { Tinymce.custom_config_ingredients(page) }

        before do
          expect(page).to receive(:descendent_element_definitions) { element_definitions }
        end

        it "returns an array of ingredient definitions that contain custom tinymce config
        and element name" do
          is_expected.to be_an(Array)
          is_expected.to include({
            "element" => element_definition["name"],
          }.merge(ingredient_definition))
        end

        context "with no ingredients having custom tinymce config" do
          let(:ingredient_definition) do
            { "role" => "text" }
          end

          it { is_expected.to eq([]) }
        end

        context "with element definition having nil as ingredients value" do
          let(:element_definition) do
            {
              "name" => "element",
              "ingredients" => nil,
            }
          end

          it "returns empty array" do
            is_expected.to eq([])
          end
        end

        context "with ingredient settings tinymce set to true only" do
          let(:element_definition) do
            {
              "name" => "element",
              "ingredients" => [
                "role" => "headline",
                "settings" => {
                  "tinymce" => true,
                },
              ],
            }
          end

          it "returns empty array" do
            is_expected.to eq([])
          end
        end

        context "with nestable_elements defined" do
          let(:element_definitions) do
            [
              element_definition,
              {
                "name" => "nested_element",
                "ingredients" => [ingredient_definition],
              },
            ]
          end

          it "includes these configs" do
            is_expected.to include({
              "element" => element_definition["name"],
            }.merge(ingredient_definition))
          end
        end
      end
    end
  end
end
