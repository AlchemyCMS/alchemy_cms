require 'spec_helper'

module Alchemy
  describe Admin::TagsHelper do

    let(:tag)    { mock_model(ActsAsTaggableOn::Tag, name: 'foo', count: 1) }
    let(:tag2)   { mock_model(ActsAsTaggableOn::Tag, name: 'abc', count: 1) }
    let(:params) { {controller: 'admin/attachments', action: 'index', use_route: 'alchemy', tagged_with: 'foo'} }

    describe '#render_tag_list' do
      context "with tagged objects" do
        before { Attachment.stub(:tag_counts).and_return([tag, tag2]) }

        it "returns a tag list as <li> tags" do
          helper.render_tag_list('Alchemy::Attachment', params).should match(/li/)
        end

        it "has the tags name in the li's name attribute" do
          helper.render_tag_list('Alchemy::Attachment', params).should match(/li.+name="#{tag.name}"/)
        end

        it "has active class if tag is present in params" do
          helper.render_tag_list('Alchemy::Attachment', params).should match(/li.+class="active"/)
        end

        it "tags are sorted alphabetically" do
          helper.render_tag_list('Alchemy::Attachment', params).should match(/li.+name="#{tag2.name}.+li.+name="#{tag.name}/)
        end

        context "with lowercase and uppercase tag names mixed" do
          let(:tag) { mock_model(ActsAsTaggableOn::Tag, name: 'Foo', count: 1) }

          it "tags are sorted alphabetically correctly" do
            helper.render_tag_list('Alchemy::Attachment', params).should match(/li.+name="#{tag2.name}.+li.+name="#{tag.name}/)
          end
        end

        it "output is html_safe" do
          helper.render_tag_list('Alchemy::Attachment', params).html_safe?.should be_true
        end
      end

      context "without any tagged objects" do
        it "returns empty string" do
          render_tag_list('Alchemy::Attachment', params).should be_empty
        end
      end

      context "with nil given as class_name parameter" do
        it "raises argument error" do
          expect { render_tag_list(nil, params) }.to raise_error(ArgumentError)
        end
      end
    end

    describe '#tag_list_tag_active?' do
      context "the tag is in params" do
        it "returns true" do
          tag_list_tag_active?(tag, params).should be_true
        end
      end

      context "params[:tagged_with] is not present" do
        it "returns false" do
          tag_list_tag_active?(tag, {}).should be_false
        end
      end
    end

    describe "#filtered_by_tag?" do
      it "should return true if the filterlist contains the given tag" do
        controller.params[:tagged_with] = "foo,bar,baz"
        helper.filtered_by_tag?(tag).should == true
      end

      it "should return false if the filterlist does not contain the given tag" do
        controller.params[:tagged_with] = "bar,baz"
        helper.filtered_by_tag?(tag).should == false
      end
    end

    describe "#add_to_tag_filter" do
      context "if params[:tagged_with] is not present" do
        it "should return an Array with the given tag name" do
          helper.add_to_tag_filter(tag).should == ["foo"]
        end
      end

      context "if params[:tagged_with] contains some tag names" do
        it "should return an Array of tag names including the given one" do
          controller.params[:tagged_with] = "bar,baz"
          helper.add_to_tag_filter(tag).should == ["bar", "baz", "foo"]
        end
      end
    end

    describe "#remove_from_tag_filter" do
      context "if params[:tagged_with] is not present" do
        it "should return an empty Array" do
          helper.remove_from_tag_filter(tag).should be_empty
        end
      end

      context "if params[:tagged_with] contains some tag names" do
        it "should return an Array of tag names without the given one" do
          controller.params[:tagged_with] = "bar,baz,foo"
          helper.remove_from_tag_filter(tag).should == ["bar", "baz"]
        end
      end
    end

  end
end