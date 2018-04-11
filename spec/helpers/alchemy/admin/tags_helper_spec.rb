# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Admin::TagsHelper do
    let(:tag)  { mock_model(Gutentag::Tag, name: 'foo', count: 1) }
    let(:tag2) { mock_model(Gutentag::Tag, name: 'abc', count: 1) }

    let(:params) do
      ActionController::Parameters.new(tagged_with: 'foo')
    end

    before do
      allow(helper).to receive(:search_filter_params) do
        params.permit!.merge(controller: 'admin/attachments', action: 'index', use_route: 'alchemy')
      end
    end

    describe '#render_tag_list' do
      subject { helper.render_tag_list('Alchemy::Attachment') }

      context "with tagged objects" do
        before { allow(Attachment).to receive(:tag_counts).and_return([tag, tag2]) }

        it "returns a tag list as <li> tags" do
          is_expected.to match(/li/)
        end

        it "has the tags name in the li's name attribute" do
          is_expected.to match(/li.+name="#{tag.name}"/)
        end

        it "has active class if tag is present in params" do
          is_expected.to match(/li.+class="active"/)
        end

        it "tags are sorted alphabetically" do
          is_expected.to match(/li.+name="#{tag2.name}.+li.+name="#{tag.name}/)
        end

        context "with lowercase and uppercase tag names mixed" do
          let(:tag) { mock_model(Gutentag::Tag, name: 'Foo', count: 1) }

          it "tags are sorted alphabetically correctly" do
            is_expected.to match(/li.+name="#{tag2.name}.+li.+name="#{tag.name}/)
          end
        end

        it "output is html_safe" do
          expect(subject.html_safe?).to be(true)
        end

        context "when filter and search params are present" do
          let(:params) do
            ActionController::Parameters.new(
              filter: 'foo',
              q: {name_eq: 'foo'}
            )
          end

          it 'keeps them' do
            is_expected.to match(/filter/)
            is_expected.to match(/name_eq/)
          end
        end
      end

      context "without any tagged objects" do
        it "returns empty string" do
          is_expected.to be_empty
        end
      end

      context "with nil given as class_name parameter" do
        it "raises argument error" do
          expect { helper.render_tag_list(nil) }.to raise_error(ArgumentError)
        end
      end
    end

    describe "#filtered_by_tag?" do
      subject { helper.filtered_by_tag?(tag) }

      context 'if the filter list params contains the given tag' do
        let(:params) do
          ActionController::Parameters.new(tagged_with: 'foo,bar,baz')
        end

        it { is_expected.to eq(true) }
      end

      context 'if the filter list params does not contain the given tag' do
        let(:params) do
          ActionController::Parameters.new(tagged_with: 'bar,baz')
        end

        it { is_expected.to eq(false) }
      end

      context "params[:tagged_with] is not present" do
        let(:params) do
          ActionController::Parameters.new
        end

        it { is_expected.to eq(false) }
      end
    end

    describe "#tags_for_filter" do
      subject { helper.tags_for_filter(current: tag) }

      context "if params[:tagged_with] is not present" do
        let(:params) do
          ActionController::Parameters.new
        end

        it "should return a String with the given tag name" do
          is_expected.to eq("foo")
        end
      end

      context "if params[:tagged_with] contains some tag names" do
        let(:params) do
          ActionController::Parameters.new(tagged_with: 'bar,baz')
        end

        it "should return a String of tag names including the given one" do
          is_expected.to eq("bar,baz,foo")
        end
      end

      context "if params[:tagged_with] contains current tag name" do
        let(:params) do
          ActionController::Parameters.new(tagged_with: 'bar,baz,foo')
        end

        it "should return a String of tag names without the current one" do
          is_expected.to eq("bar,baz")
        end
      end
    end
  end
end
