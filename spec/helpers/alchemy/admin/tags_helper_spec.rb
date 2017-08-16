require 'spec_helper'

module Alchemy
  describe Admin::TagsHelper do
    let(:tag)  { mock_model(ActsAsTaggableOn::Tag, name: 'foo', count: 1) }
    let(:tag2) { mock_model(ActsAsTaggableOn::Tag, name: 'abc', count: 1) }

    let(:params) do
      ActionController::Parameters.new({
        controller: 'alchemy/admin/attachments',
        action: 'index',
        use_route: 'alchemy',
        tagged_with: 'foo'
      })
    end

    before do
      allow(helper).to receive(:params) { params }
      allow(helper).to receive(:options_from_params) do
        ActionController::Parameters.new.permit!
      end
    end

    describe '#render_tag_list' do
      context "with tagged objects" do
        before { allow(Attachment).to receive(:tag_counts).and_return([tag, tag2]) }

        it "returns a tag list as <li> tags" do
          expect(helper.render_tag_list('Alchemy::Attachment')).to match(/li/)
        end

        it "has the tags name in the li's name attribute" do
          expect(helper.render_tag_list('Alchemy::Attachment')).to match(/li.+name="#{tag.name}"/)
        end

        it "has active class if tag is present in params" do
          expect(helper.render_tag_list('Alchemy::Attachment')).to match(/li.+class="active"/)
        end

        it "tags are sorted alphabetically" do
          expect(helper.render_tag_list('Alchemy::Attachment')).to match(/li.+name="#{tag2.name}.+li.+name="#{tag.name}/)
        end

        context "with lowercase and uppercase tag names mixed" do
          let(:tag) { mock_model(ActsAsTaggableOn::Tag, name: 'Foo', count: 1) }

          it "tags are sorted alphabetically correctly" do
            expect(helper.render_tag_list('Alchemy::Attachment')).to match(/li.+name="#{tag2.name}.+li.+name="#{tag.name}/)
          end
        end

        it "output is html_safe" do
          expect(helper.render_tag_list('Alchemy::Attachment').html_safe?).to be_truthy
        end

        context "when filter and search params are present" do
          let(:params) do
            ActionController::Parameters.new({
              controller: 'alchemy/admin/attachments',
              action: 'index',
              use_route: 'alchemy',
              filter: 'foo',
              q: {name_eq: 'foo'}
            })
          end

          it 'keeps them' do
            expect(helper.render_tag_list('Alchemy::Attachment')).to match(/filter/)
            expect(helper.render_tag_list('Alchemy::Attachment')).to match(/name_eq/)
          end
        end
      end

      context "without any tagged objects" do
        it "returns empty string" do
          expect(helper.render_tag_list('Alchemy::Attachment')).to be_empty
        end
      end

      context "with nil given as class_name parameter" do
        it "raises argument error" do
          expect { helper.render_tag_list(nil) }.to raise_error(ArgumentError)
        end
      end
    end

    describe '#tag_list_tag_active?' do
      context "the tag is in params" do
        it "returns true" do
          expect(helper.tag_list_tag_active?(tag)).to be_truthy
        end
      end

      context "params[:tagged_with] is not present" do
        let(:params) do
          ActionController::Parameters.new({
            controller: 'alchemy/admin/attachments',
            action: 'index',
            use_route: 'alchemy'
          })
        end

        it "returns false" do
          expect(helper.tag_list_tag_active?(tag)).to be_falsey
        end
      end
    end

    describe "#filtered_by_tag?" do
      it "should return true if the filterlist contains the given tag" do
        controller.params[:tagged_with] = "foo,bar,baz"
        expect(helper.filtered_by_tag?(tag)).to eq(true)
      end

      context 'if the filterlist does not contain the given tag' do
        let(:params) do
          ActionController::Parameters.new({
            controller: 'alchemy/admin/attachments',
            action: 'index',
            use_route: 'alchemy',
            tagged_with: 'bar,baz'
          })
        end

        it "should return false" do
          expect(helper.filtered_by_tag?(tag)).to eq(false)
        end
      end
    end

    describe "#add_to_tag_filter" do
      context "if params[:tagged_with] is not present" do
        let(:params) do
          ActionController::Parameters.new({
            controller: 'alchemy/admin/attachments',
            action: 'index',
            use_route: 'alchemy'
          })
        end

        it "should return an Array with the given tag name" do
          expect(helper.add_to_tag_filter(tag)).to eq(["foo"])
        end
      end

      context "if params[:tagged_with] contains some tag names" do
        let(:params) do
          ActionController::Parameters.new({
            controller: 'alchemy/admin/attachments',
            action: 'index',
            use_route: 'alchemy',
            tagged_with: 'bar,baz'
          })
        end

        it "should return an Array of tag names including the given one" do
          expect(helper.add_to_tag_filter(tag)).to eq(["bar", "baz", "foo"])
        end
      end
    end

    describe "#remove_from_tag_filter" do
      context "if params[:tagged_with] is not present" do
        let(:params) do
          ActionController::Parameters.new({
            controller: 'alchemy/admin/attachments',
            action: 'index',
            use_route: 'alchemy'
          })
        end

        it "should return an empty Array" do
          expect(helper.remove_from_tag_filter(tag)).to be_empty
        end
      end

      context "if params[:tagged_with] contains some tag names" do
        let(:params) do
          ActionController::Parameters.new({
            controller: 'alchemy/admin/attachments',
            action: 'index',
            use_route: 'alchemy',
            tagged_with: 'bar,baz,foo'
          })
        end

        it "should return an Array of tag names without the given one" do
          expect(helper.remove_from_tag_filter(tag)).to eq(["bar", "baz"])
        end
      end
    end
  end
end
