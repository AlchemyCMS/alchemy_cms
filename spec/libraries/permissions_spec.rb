require 'spec_helper'
require 'cancan/matchers'

describe Alchemy::Permissions do
  subject { ability }

  let(:ability)                 { Alchemy::Permissions.new(user) }
  let(:attachment)              { mock_model(Alchemy::Attachment, restricted?: false) }
  let(:restricted_attachment)   { mock_model(Alchemy::Attachment, restricted?: true) }
  let(:picture)                 { mock_model(Alchemy::Picture, restricted?: false) }
  let(:restricted_picture)      { mock_model(Alchemy::Picture, restricted?: true) }
  let(:public_page)             { build_stubbed(:public_page, restricted: false) }
  let(:unpublic_page)           { build_stubbed(:page, public: false) }
  let(:visible_page)            { build_stubbed(:page, restricted: false, visible: true) }
  let(:not_visible_page)        { build_stubbed(:public_page, restricted: false, visible: false) }
  let(:restricted_page)         { build_stubbed(:public_page, public: true, restricted: true) }
  let(:visible_restricted_page) { build_stubbed(:page, visible: true, restricted: true) }
  let(:published_element)       { mock_model(Alchemy::Element, public: true, page: public_page) }
  let(:restricted_element)      { mock_model(Alchemy::Element, public: true, page: restricted_page) }

  context "A guest user" do
    let(:user) { nil }

    it "can only download not restricted attachments" do
      should be_able_to(:download, attachment)
      should_not be_able_to(:download, restricted_attachment)
    end

    it "can only see not restricted attachments" do
      should be_able_to(:show, attachment)
      should_not be_able_to(:show, restricted_attachment)
    end

    it "can only download not restricted pictures" do
      should be_able_to(:download, picture)
      should_not be_able_to(:download, restricted_picture)
    end

    it "can only see not restricted pictures" do
      should be_able_to(:show, picture)
      should_not be_able_to(:show, restricted_picture)
    end

    it "can only visit not restricted pages" do
      should be_able_to(:show, public_page)
      should_not be_able_to(:show, restricted_page)
    end

    it "can only see visible not restricted pages" do
      should be_able_to(:see, visible_page)
      should_not be_able_to(:see, not_visible_page)
    end

    it "can only see public not restricted elements" do
      should be_able_to(:show, published_element)
      should_not be_able_to(:show, restricted_element)
    end
  end

  context "A member" do
    let(:user) { member_user }

    it "can download all attachments" do
      should be_able_to(:download, attachment)
      should be_able_to(:download, restricted_attachment)
    end

    it "can see all attachments" do
      should be_able_to(:show, attachment)
      should be_able_to(:show, restricted_attachment)
    end

    it "can download all pictures" do
      should be_able_to(:download, picture)
      should be_able_to(:download, restricted_picture)
    end

    it "can see all pictures" do
      should be_able_to(:show, picture)
      should be_able_to(:show, restricted_picture)
    end

    it "can visit restricted pages" do
      should be_able_to(:show, public_page)
      should be_able_to(:show, restricted_page)
    end

    it "can see visible restricted pages" do
      should be_able_to(:see, visible_page)
      should be_able_to(:see, visible_restricted_page)
    end

    it "can not see invisible pages" do
      should_not be_able_to(:see, not_visible_page)
    end

    it "can see public restricted elements" do
      should be_able_to(:show, published_element)
      should be_able_to(:show, restricted_element)
    end
  end

  context "An author" do
    let(:user) { author_user }

    it "can visit the dashboard" do
      should be_able_to(:index, :alchemy_admin_dashboard)
      should be_able_to(:info, :alchemy_admin_dashboard)
    end

    it "can see picture thumbnails" do
      should be_able_to(:thumbnail, Alchemy::Picture)
    end

    it "can edit page content" do
      should be_able_to(:show, unpublic_page)
      should be_able_to(:index, Alchemy::Page)
      should be_able_to(:info, Alchemy::Page)
      should be_able_to(:configure, Alchemy::Page)
      should be_able_to(:update, Alchemy::Page)
      should be_able_to(:fold, Alchemy::Page)
      should be_able_to(:link, Alchemy::Page)
      should be_able_to(:visit, Alchemy::Page)
      should be_able_to(:unlock, Alchemy::Page)
      should be_able_to(:publish, Alchemy::Page)
    end

    it "can manage elements" do
      should be_able_to(:manage, Alchemy::Element)
    end

    it "can see all attachments" do
      should be_able_to(:read, Alchemy::Attachment)
      should be_able_to(:download, Alchemy::Attachment)
    end

    it "can see all pictures" do
      should be_able_to(:read, Alchemy::Picture)
      should be_able_to(:info, Alchemy::Picture)
    end

    it "can manage contents" do
      should be_able_to(:manage, Alchemy::Content)
    end

    it "can manage essences" do
      should be_able_to(:manage, Alchemy::EssencePicture)
      should be_able_to(:manage, Alchemy::EssenceFile)
    end

    it "can see the trash" do
      should be_able_to(:index, :trash)
    end

    it "can manage the clipboard" do
      should be_able_to(:manage, :alchemy_admin_clipboard)
    end

    it "can see tags" do
      should be_able_to(:read, Alchemy::Tag)
      should be_able_to(:autocomplete, Alchemy::Tag)
    end

    it "can index layoutpages" do
      should be_able_to(:index, :alchemy_admin_layoutpages)
    end
  end

  context "An editor" do
    let(:user) { editor_user }

    it "can manage pages" do
      should be_able_to(:copy, Alchemy::Page)
      should be_able_to(:copy_language_tree, Alchemy::Page)
      should be_able_to(:create, Alchemy::Page)
      should be_able_to(:destroy, Alchemy::Page)
      should be_able_to(:flush, Alchemy::Page)
      should be_able_to(:order, Alchemy::Page)
      should be_able_to(:sort, Alchemy::Page)
      should be_able_to(:switch_language, Alchemy::Page)
    end

    it "can not see invisible pages" do
      should_not be_able_to(:see, not_visible_page)
    end

    it "can clear the trash" do
      should be_able_to(:clear, :trash)
    end

    it "can manage attachments" do
      should be_able_to(:manage, Alchemy::Attachment)
    end

    it "can manage pictures" do
      should be_able_to(:manage, Alchemy::Picture)
    end

    it "can manage tags" do
      should be_able_to(:manage, Alchemy::Tag)
    end
  end

  context "An admin" do
    let(:user) { admin_user }

    it "can check for alchemy updates" do
      should be_able_to(:update_check, :alchemy_admin_dashboard)
    end

    it "can manage languages" do
      should be_able_to(:manage, Alchemy::Language)
    end

    it "can manage sites" do
      should be_able_to(:manage, Alchemy::Site)
    end
  end
end
