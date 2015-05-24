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
  let(:published_element)       { mock_model(Alchemy::Element, restricted?: false, public?: true, trashed?: false) }
  let(:restricted_element)      { mock_model(Alchemy::Element, restricted?: true, public?: true, trashed?: false) }
  let(:published_content)       { mock_model(Alchemy::Content, restricted?: false, public?: true, trashed?: false) }
  let(:restricted_content)      { mock_model(Alchemy::Content, restricted?: true, public?: true, trashed?: false) }

  context "A guest user" do
    let(:user) { nil }

    it "can only download not restricted attachments" do
      is_expected.to be_able_to(:download, attachment)
      is_expected.not_to be_able_to(:download, restricted_attachment)
    end

    it "can only see not restricted attachments" do
      is_expected.to be_able_to(:show, attachment)
      is_expected.not_to be_able_to(:show, restricted_attachment)
    end

    it "can only see not restricted pictures" do
      is_expected.to be_able_to(:show, picture)
      is_expected.to be_able_to(:thumbnail, picture)
      is_expected.to be_able_to(:zoom, picture)
      is_expected.not_to be_able_to(:show, restricted_picture)
      is_expected.not_to be_able_to(:thumbnail, restricted_picture)
      is_expected.not_to be_able_to(:zoom, restricted_picture)
    end

    it "can only visit not restricted pages" do
      is_expected.to be_able_to(:show, public_page)
      is_expected.not_to be_able_to(:show, restricted_page)
      is_expected.to be_able_to(:index, public_page)
      is_expected.not_to be_able_to(:index, restricted_page)
    end

    it "can only see visible not restricted pages" do
      is_expected.to be_able_to(:see, visible_page)
      is_expected.not_to be_able_to(:see, not_visible_page)
    end

    it "can only see public not restricted elements" do
      is_expected.to be_able_to(:show, published_element)
      is_expected.not_to be_able_to(:show, restricted_element)
      is_expected.to be_able_to(:index, published_element)
      is_expected.not_to be_able_to(:index, restricted_element)
    end

    it "can only see public not restricted contents" do
      is_expected.to be_able_to(:show, published_content)
      is_expected.not_to be_able_to(:show, restricted_content)
      is_expected.to be_able_to(:index, published_content)
      is_expected.not_to be_able_to(:index, restricted_content)
    end
  end

  context "A member" do
    let(:user) { build(:alchemy_dummy_user) }

    it "can download all attachments" do
      is_expected.to be_able_to(:download, attachment)
      is_expected.to be_able_to(:download, restricted_attachment)
    end

    it "can see all attachments" do
      is_expected.to be_able_to(:show, attachment)
      is_expected.to be_able_to(:show, restricted_attachment)
    end

    it "can see all pictures" do
      is_expected.to be_able_to(:show, picture)
      is_expected.to be_able_to(:thumbnail, picture)
      is_expected.to be_able_to(:zoom, picture)
      is_expected.to be_able_to(:show, restricted_picture)
      is_expected.to be_able_to(:thumbnail, restricted_picture)
      is_expected.to be_able_to(:zoom, restricted_picture)
    end

    it "can visit restricted pages" do
      is_expected.to be_able_to(:show, public_page)
      is_expected.to be_able_to(:show, restricted_page)
      is_expected.to be_able_to(:index, public_page)
      is_expected.to be_able_to(:index, restricted_page)
    end

    it "can see visible restricted pages" do
      is_expected.to be_able_to(:see, visible_page)
      is_expected.to be_able_to(:see, visible_restricted_page)
    end

    it "can not see invisible pages" do
      is_expected.not_to be_able_to(:see, not_visible_page)
    end

    it "can see public restricted elements" do
      is_expected.to be_able_to(:show, published_element)
      is_expected.to be_able_to(:show, restricted_element)
      is_expected.to be_able_to(:index, published_element)
      is_expected.to be_able_to(:index, restricted_element)
    end

    it "can see public restricted contents" do
      is_expected.to be_able_to(:show, published_content)
      is_expected.to be_able_to(:show, restricted_content)
      is_expected.to be_able_to(:index, published_content)
      is_expected.to be_able_to(:index, restricted_content)
    end
  end

  context "An author" do
    let(:user) { build(:alchemy_dummy_user, :as_author) }

    it "can leave the admin area" do
      is_expected.to be_able_to(:leave, :alchemy_admin)
    end

    it "can visit the dashboard" do
      is_expected.to be_able_to(:index, :alchemy_admin_dashboard)
      is_expected.to be_able_to(:info, :alchemy_admin_dashboard)
    end

    it "can see picture thumbnails" do
      is_expected.to be_able_to(:thumbnail, Alchemy::Picture)
    end

    it "can edit page content" do
      is_expected.to be_able_to(:show, unpublic_page)
      is_expected.to be_able_to(:index, Alchemy::Page)
      is_expected.to be_able_to(:info, Alchemy::Page)
      is_expected.to be_able_to(:configure, Alchemy::Page)
      is_expected.to be_able_to(:update, Alchemy::Page)
      is_expected.to be_able_to(:fold, Alchemy::Page)
      is_expected.to be_able_to(:link, Alchemy::Page)
      is_expected.to be_able_to(:visit, Alchemy::Page)
      is_expected.to be_able_to(:unlock, Alchemy::Page)
    end

    it "can not publish pages" do
      is_expected.to_not be_able_to(:publish, Alchemy::Page)
    end

    it "can manage elements" do
      is_expected.to be_able_to(:manage, Alchemy::Element)
    end

    it "can see all attachments" do
      is_expected.to be_able_to(:read, Alchemy::Attachment)
      is_expected.to be_able_to(:download, Alchemy::Attachment)
    end

    it "can see all pictures" do
      is_expected.to be_able_to(:read, Alchemy::Picture)
      is_expected.to be_able_to(:info, Alchemy::Picture)
    end

    it "can manage contents" do
      is_expected.to be_able_to(:manage, Alchemy::Content)
    end

    it "can manage essences" do
      is_expected.to be_able_to(:manage, Alchemy::EssencePicture)
      is_expected.to be_able_to(:manage, Alchemy::EssenceFile)
    end

    it "can see the trash" do
      is_expected.to be_able_to(:index, :trash)
    end

    it "can manage the clipboard" do
      is_expected.to be_able_to(:manage, :alchemy_admin_clipboard)
    end

    it "can see tags" do
      is_expected.to be_able_to(:read, Alchemy::Tag)
      is_expected.to be_able_to(:autocomplete, Alchemy::Tag)
    end

    it "can index layoutpages" do
      is_expected.to be_able_to(:index, :alchemy_admin_layoutpages)
    end
  end

  context "An editor" do
    let(:user) { build(:alchemy_dummy_user, :as_editor) }

    it "can manage pages" do
      is_expected.to be_able_to(:copy, Alchemy::Page)
      is_expected.to be_able_to(:copy_language_tree, Alchemy::Page)
      is_expected.to be_able_to(:create, Alchemy::Page)
      is_expected.to be_able_to(:destroy, Alchemy::Page)
      is_expected.to be_able_to(:flush, Alchemy::Page)
      is_expected.to be_able_to(:order, Alchemy::Page)
      is_expected.to be_able_to(:sort, Alchemy::Page)
      is_expected.to be_able_to(:switch_language, Alchemy::Page)
    end

    it "can publish pages" do
      is_expected.to be_able_to(:publish, Alchemy::Page)
    end

    it "can not see invisible pages" do
      is_expected.not_to be_able_to(:see, not_visible_page)
    end

    it "can clear the trash" do
      is_expected.to be_able_to(:clear, :trash)
    end

    it "can manage attachments" do
      is_expected.to be_able_to(:manage, Alchemy::Attachment)
    end

    it "can manage pictures" do
      is_expected.to be_able_to(:manage, Alchemy::Picture)
    end

    it "can manage tags" do
      is_expected.to be_able_to(:manage, Alchemy::Tag)
    end
  end

  context "An admin" do
    let(:user) { build(:alchemy_dummy_user, :as_admin) }

    it "can check for alchemy updates" do
      is_expected.to be_able_to(:update_check, :alchemy_admin_dashboard)
    end

    it "can manage languages" do
      is_expected.to be_able_to(:manage, Alchemy::Language)
    end

    it "can manage sites" do
      is_expected.to be_able_to(:manage, Alchemy::Site)
    end
  end

  context "A logged in user without a role" do
    let(:user) { mock_model(Alchemy.user_class, alchemy_roles: []) }

    it "can only see visible not restricted pages (like the guest role)" do
      is_expected.to be_able_to(:see, visible_page)
      is_expected.not_to be_able_to(:see, not_visible_page)
    end
  end
end
