require 'spec_helper'

describe 'Page editing feature' do
  let(:a_page) { create(:page) }

  context 'as author' do
    before { authorize_user(:as_author) }

    it 'cannot publish page.' do
      visit alchemy.edit_admin_page_path(a_page)
      expect(page).to_not have_selector('#publish_page_form')
    end
  end

  context 'as editor' do
    before { authorize_user(:as_editor) }

    it 'can publish page.' do
      visit alchemy.edit_admin_page_path(a_page)
      find('#publish_page_form button').click
      expect(page).to have_content Alchemy::I18n.t(:page_published, name: a_page.name)
    end

    context 'while editing a global page' do
      let(:a_page) { create(:page, layoutpage: true) }

      it 'cannot publish page.' do
        visit alchemy.edit_admin_page_path(a_page)
        expect(page).to_not have_selector('#publish_page_form')
      end
    end
  end

  context 'as admin' do
    let(:a_page) { create(:public_page, visible: true) }

    before { authorize_user(:as_admin) }

    context "in configure overlay" do
      context "when editing a normal page" do
        it "should show all relevant input fields" do
          visit alchemy.configure_admin_page_path(a_page)
          expect(page).to have_selector('input#page_urlname')
          expect(page).to have_selector('input#page_title')
          expect(page).to have_selector('input#page_robot_index')
          expect(page).to have_selector('input#page_robot_follow')
        end

        context "with sitemaps show_flag config option set to true" do
          before do
            allow(Alchemy::Config).to receive(:get) do |arg|
              arg == :sitemap ? {'show_flag' => true} : Alchemy::Config.show[arg.to_s]
            end
          end

          it "should show sitemap checkbox" do
            visit alchemy.configure_admin_page_path(a_page)
            expect(page).to have_selector('input[type="checkbox"]#page_sitemap')
          end
        end

        context "with sitemaps show_flag config option set to false" do
          before do
            allow(Alchemy::Config).to receive(:get) do |arg|
              arg == :sitemap ? {'show_flag' => false} : Alchemy::Config.show[arg.to_s]
            end
          end

          it "should not show sitemap checkbox" do
            visit alchemy.configure_admin_page_path(a_page)
            expect(page).to_not have_selector('input[type="checkbox"]#page_sitemap')
          end
        end
      end

      context "when editing a global page" do
        let(:layout_page) { create(:page, layoutpage: true) }

        it "should not show the input fields for normal pages" do
          visit alchemy.edit_admin_layoutpage_path(layout_page)
          expect(page).to_not have_selector('input#page_urlname')
          expect(page).to_not have_selector('input#page_title')
          expect(page).to_not have_selector('input#page_robot_index')
          expect(page).to_not have_selector('input#page_robot_follow')
        end
      end

      context "when page is taggable" do
        before do
          expect_any_instance_of(Alchemy::Page)
            .to receive(:taggable?).and_return(true)
        end

        it "should show the tag_list input field" do
          visit alchemy.configure_admin_page_path(a_page)
          expect(page).to have_selector('input#page_tag_list')
        end
      end
    end

    context "in preview frame" do
      it "the menubar does not render on the page" do
        visit alchemy.admin_page_path(a_page)
        expect(page).not_to have_selector('#alchemy_menubar')
      end

      it "navigation links are not clickable" do
        visit alchemy.admin_page_path(a_page)
        within('#navigation') do
          expect(page).to have_selector('a[href="javascript: void(0)"]')
        end
      end
    end

    context 'in element panel' do
      let!(:everything_page) do
        create(:page, page_layout: 'everything', do_not_autogenerate: false)
      end

      it "renders essence editors for all elements" do
        visit alchemy.admin_elements_path(page_id: everything_page.id)

        expect(page).to have_selector('div.content_editor.essence_boolean')
        expect(page).to have_selector('div.content_editor.essence_date')
        expect(page).to have_selector('div.content_editor.essence_file')
        expect(page).to have_selector('div.content_editor.essence_html_editor')
        expect(page).to have_selector('div.content_editor.essence_link')
        expect(page).to have_selector('div.content_editor.essence_picture_editor')
        expect(page).to have_selector('div.content_editor.essence_richtext')
        expect(page).to have_selector('div.content_editor.essence_select')
        expect(page).to have_selector('div.content_editor.essence_text')
      end
    end
  end
end
