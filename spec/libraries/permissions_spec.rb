# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

describe Alchemy::Permissions do
  subject { ability }

  let(:ability) { Alchemy::Permissions.new(user) }
  let(:attachment) { mock_model(Alchemy::Attachment, restricted?: false) }
  let(:restricted_attachment) { mock_model(Alchemy::Attachment, restricted?: true) }
  let(:picture) { mock_model(Alchemy::Picture, restricted?: false) }
  let(:restricted_picture) { mock_model(Alchemy::Picture, restricted?: true) }
  let(:public_page) { build(:alchemy_page, :public, restricted: false) }
  let(:unpublic_page) { build(:alchemy_page) }
  let(:restricted_page) { build(:alchemy_page, :public, restricted: true) }
  let(:published_element) { mock_model(Alchemy::Element, restricted?: false, public?: true) }
  let(:restricted_element) { mock_model(Alchemy::Element, restricted?: true, public?: true) }
  let(:language) { build(:alchemy_language) }
  let(:user_with_languages) { Alchemy::UserWithLanguages.new(user) }

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

    it "can only visit not restricted pages" do
      is_expected.to be_able_to(:show, public_page)
      is_expected.not_to be_able_to(:show, restricted_page)
      is_expected.to be_able_to(:index, public_page)
      is_expected.not_to be_able_to(:index, restricted_page)
    end

    it "can only see public not restricted elements" do
      is_expected.to be_able_to(:show, published_element)
      is_expected.not_to be_able_to(:show, restricted_element)
      is_expected.to be_able_to(:index, published_element)
      is_expected.not_to be_able_to(:index, restricted_element)
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

    it "can visit restricted pages" do
      is_expected.to be_able_to(:show, public_page)
      is_expected.to be_able_to(:show, restricted_page)
      is_expected.to be_able_to(:index, public_page)
      is_expected.to be_able_to(:index, restricted_page)
    end

    it "can see public restricted elements" do
      is_expected.to be_able_to(:show, published_element)
      is_expected.to be_able_to(:show, restricted_element)
      is_expected.to be_able_to(:index, published_element)
      is_expected.to be_able_to(:index, restricted_element)
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

    context "on a page editable by them" do
      before { allow(unpublic_page).to receive(:editable_by?).with(user) { true } }

      it "can edit page content" do
        [:show, :index, :info, :configure, :update, :fold, :link, :visit, :unlock].each do |action|
          is_expected.to be_able_to(action, unpublic_page)
          is_expected.to be_able_to(action, Alchemy::Page)
        end
      end
    end

    context "on a page not editable by them" do
      before { allow(unpublic_page).to receive(:editable_by?).with(user) { false } }

      it "cannot edit page content" do
        [:info, :configure, :update, :fold, :link, :visit, :unlock].each do |action|
          is_expected.not_to be_able_to(action, unpublic_page)
        end
      end
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
      is_expected.to be_able_to(:url, Alchemy::Picture)
    end

    it "can manage ingredients" do
      is_expected.to be_able_to(:manage, Alchemy::Ingredient)
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

    it "can only manage nodes for languages they have access to" do
      user = build(:alchemy_dummy_user, :as_author, languages: create_list(:alchemy_language, 1))
      is_expected.to be_able_to(:manage, create(:alchemy_node, language: user.languages.first))
      is_expected.not_to be_able_to(:manage, create(:alchemy_node, language: create(:alchemy_language, :german)))
    end
  end

  context "An editor" do
    let(:user) { build(:alchemy_dummy_user, :as_editor) }

    context "on a page in a language they can access" do
      before { unpublic_page.save }

      let(:user) { create(:alchemy_dummy_user, :as_editor, languages: [unpublic_page.language]) }

      it "can copy/copy language tree/flush/order/switch_language it" do
        [:copy, :copy_language_tree, :flush, :order, :switch_language].each do |action|
          is_expected.to be_able_to(action, unpublic_page)
          expect(Alchemy::Page.accessible_by(subject, action)).to include unpublic_page
        end
      end
    end

    context "on a page in a language they can access" do
      before { unpublic_page.save }

      let(:user) { create(:alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :german)) }

      it "cannot copy/copy language tree/flush/order/switch_language it" do
        [:copy, :copy_language_tree, :flush, :order, :switch_language].each do |action|
          is_expected.not_to be_able_to(action, unpublic_page)
          expect(Alchemy::Page.accessible_by(subject, action)).not_to include unpublic_page
        end
      end

      context "when it is editable by them" do
        before { allow(unpublic_page).to receive(:editable_by?).with(user) { true } }

        it "can create and destroy" do
          is_expected.to be_able_to :create, unpublic_page
          is_expected.to be_able_to :destroy, unpublic_page
        end
      end

      context "when it is not editable by them" do
        before { allow(unpublic_page).to receive(:editable_by?).with(user) { false } }

        it "can create and destroy" do
          is_expected.not_to be_able_to :create, unpublic_page
          is_expected.not_to be_able_to :destroy, unpublic_page
        end
      end
    end

    context "if page language is public" do
      let(:language) { create(:alchemy_language, :german, public: true) }
      let(:page) { create(:alchemy_page, language: language) }

      context "and in a language they have access to" do
        let(:user) { build :alchemy_dummy_user, :as_editor, languages: [language] }

        context "and it is editable by them" do
          before { allow(page).to receive(:editable_by?).with(user) { true } }

          it "can publish pages" do
            is_expected.to be_able_to(:publish, page)
          end
        end

        context "and it is not editable by them" do
          before { allow(page).to receive(:editable_by?).with(user) { false } }

          it "cannot publish pages" do
            is_expected.not_to be_able_to(:publish, page)
          end
        end
      end

      context "and not in a language accessible to them" do
        let(:user) { build :alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :klingon) }

        it "cannot publish pages" do
          is_expected.not_to be_able_to(:publish, page)
        end
      end
    end

    context "if page language is not public" do
      let(:language) { create(:alchemy_language, :german, public: false) }
      let(:page) { create(:alchemy_page, language: language) }

      before { allow(page).to receive(:editable_by?).with(user) { true } }

      it "cannot publish pages" do
        is_expected.to_not be_able_to(:publish, page)
      end
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

    it "can index languages in sites they can access" do
      user = create(:alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :german))

      is_expected.to be_able_to(
        :index, 
        create(:alchemy_language, site_id: user_with_languages.accessible_site_ids.first)
      )
    end

    it "cannot index languages in sites they cannot access" do
      user = create(:alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :german))

      is_expected.not_to be_able_to(
        :index, 
        create(:alchemy_language, site_id: create(:alchemy_site, host: "abc.def").id)
      )
    end
  end

  context "An admin" do
    let(:user) { build(:alchemy_dummy_user, :as_admin) }

    it "can check for alchemy updates" do
      is_expected.to be_able_to(:update_check, :alchemy_admin_dashboard)
    end

    it "can index a site they can access" do
      user = create(:alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :german))
      
      is_expected.to be_able_to(:index, user_with_languages.accessible_sites.first)
    end

    it "cannot index a site they cannot access" do
      user = create(:alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :german))
      
      is_expected.to be_able_to(:index, create(:alchemy_site, host: "abc.def"))
    end

    it "can manage a language they have access to" do
      user = create(:alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :german))

      is_expected.to be_able_to(:manage, user.languages.first)
      expect(Alchemy::Language.accessible_by(subject, :manage)).to match_array(user.languages)
    end

    it "cannot manage a language they do not have access to" do
      user = create(:alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :german))

      is_expected.not_to be_able_to(:manage, create(:alchemy_language, :klingon))
    end

    it "can manage a site they can access" do
      user = create(:alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :german))

      is_expected.to be_able_to(:manage, Alchemy::UserWithLanguages.new(user).accessible_sites.first)
    end

    it "cannot manage a site they cannot access" do
      user = create(:alchemy_dummy_user, :as_editor, languages: create_list(:alchemy_language, 1, :german))

      is_expected.to be_able_to(:index, create(:alchemy_site, host: "abc.def"))
    end
  end

  context "A logged in user without a role" do
    let(:user) { mock_model(Alchemy.user_class, alchemy_roles: []) }

    it "can only see public not restricted pages (like the guest role)" do
      is_expected.to be_able_to(:show, public_page)
      is_expected.not_to be_able_to(:show, restricted_page)
    end
  end
end
