require 'ostruct'
require 'spec_helper'

module Alchemy
  describe PagesController do
    let(:default_language)      { Language.default }
    let(:default_language_root) { FactoryGirl.create(:language_root_page, language: default_language, name: 'Home', public: true) }
    let(:page) { FactoryGirl.create(:public_page, parent_id: default_language_root.id, page_layout: 'news', name: 'News', urlname: 'news', language: default_language, do_not_autogenerate: false) }

    before { allow(controller).to receive(:signup_required?).and_return(false) }

    context 'an author' do
      let(:unpublic) { create(:page, parent: default_language_root) }

      before { authorize_user(:as_author) }

      it "should not be able to visit a unpublic page" do
        expect {
          alchemy_get :show, urlname: unpublic.urlname
        }.to raise_error(ActionController::RoutingError)
      end
    end

    context "requested for a page containing a feed" do
      render_views

      it "should render a rss feed" do
        alchemy_get :show, urlname: page.urlname, format: :rss
        expect(response.content_type).to eq('application/rss+xml')
      end

      it "should include content" do
        page.elements.first.content_by_name('news_headline').essence.update_attributes({body: 'Peters Petshop'})
        alchemy_get :show, urlname: 'news', format: :rss
        expect(response.body).to match /Peters Petshop/
      end
    end

    context "requested for a page that does not contain a feed" do
      it "should render xml 404 error" do
        alchemy_get :show, urlname: default_language_root.urlname, format: :rss
        expect(response.status).to eq(404)
      end
    end

    describe "Layout rendering" do
      context "with ajax request" do
        it "should not render a layout" do
          alchemy_xhr :get, :show, urlname: page.urlname
          expect(response).to render_template(:show)
          expect(response).not_to render_template(layout: 'application')
        end
      end
    end

    describe "url nesting" do
      render_views

      let(:catalog)  { FactoryGirl.create(:public_page, name: "Catalog", urlname: 'catalog', parent: default_language_root, language: default_language, visible: true) }
      let(:products) { FactoryGirl.create(:public_page, name: "Products", urlname: 'products', parent: catalog, language: default_language, visible: true) }
      let(:product)  { FactoryGirl.create(:public_page, name: "Screwdriver", urlname: 'screwdriver', parent: products, language: default_language, do_not_autogenerate: false, visible: true) }

      before do
        allow(Alchemy.user_class).to receive(:admins).and_return(OpenStruct.new(count: 1))
        allow(Config).to receive(:get) { |arg| arg == :url_nesting ? true : false }
        product.elements.find_by_name('article').contents.essence_texts.first.essence.update_column(:body, 'screwdriver')
      end

      context "with correct levelnames in params" do
        it "should show the requested page" do
          alchemy_get :show, {urlname: 'catalog/products/screwdriver'}
          expect(response.status).to eq(200)
          expect(response.body).to have_content("screwdriver")
        end
      end

      context "with incorrect levelnames in params" do
        it "should render a 404 page" do
          expect {
            alchemy_get :show, {urlname: 'catalog/faqs/screwdriver'}
          }.to raise_error(ActionController::RoutingError)
        end
      end
    end

    context "when a non-existent page is requested" do
      it "should rescue a RoutingError with rendering a 404 page." do
        expect {
          alchemy_get :show, {urlname: 'doesntexist'}
        }.to raise_error(ActionController::RoutingError)
      end
    end

    describe '#redirect_to_public_child' do
      let(:root_page)    { FactoryGirl.create(:language_root_page, public: false) }
      let(:page)         { FactoryGirl.create(:page, parent_id: root_page.id) }
      let(:public_page)  { FactoryGirl.create(:public_page, parent_id: page.id) }

      before { controller.instance_variable_set("@page", root_page) }

      context 'as guest user' do
        context "with unpublished and published pages in page tree" do
          before do
            public_page
            root_page.reload
          end

          it "should redirect to first public child" do
            expect(controller).to receive(:redirect_page)
            controller.send(:redirect_to_public_child)
            expect(controller.instance_variable_get('@page')).to eq(public_page)
          end
        end

        context "with only unpublished pages in page tree" do
          before do
            page
            root_page.reload
          end

          it "should raise not found error" do
            expect {
              controller.send(:redirect_to_public_child)
            }.to raise_error(ActionController::RoutingError)
          end
        end
      end
    end

    describe 'Redirecting to legacy page urls' do
      context 'Request a page with legacy url' do
        let(:page)        { FactoryGirl.create(:public_page, name: 'New page name') }
        let(:second_page) { FactoryGirl.create(:public_page, name: 'Second Page') }
        let(:legacy_page) { FactoryGirl.create(:public_page, name: 'Legacy Url') }
        let!(:legacy_url) { LegacyPageUrl.create(urlname: 'legacy-url', page: page) }
        let(:legacy_url2) { LegacyPageUrl.create(urlname: 'legacy-url', page: second_page) }
        let(:legacy_url3) { LegacyPageUrl.create(urlname: 'index.php?id=2', page: second_page) }
        let(:legacy_url4) { LegacyPageUrl.create(urlname: 'index.php?option=com_content&view=article&id=48&Itemid=69', page: second_page) }
        let(:legacy_url5) { LegacyPageUrl.create(urlname: 'nested/legacy/url', page: second_page) }

        it "should redirect permanently to page that belongs to legacy page url even if url has an unknown format & get parameters" do
          expect(request).to receive(:fullpath).at_least(:once).and_return(legacy_url4.urlname)
          alchemy_get :show, urlname: legacy_url4.urlname
          expect(response.status).to eq(301)
          expect(response).to redirect_to("/#{second_page.urlname}")
        end

        it "should not pass query string for legacy routes" do
          expect(request).to receive(:fullpath).at_least(:once).and_return(legacy_url3.urlname)
          alchemy_get :show, urlname: legacy_url4.urlname
          expect(URI.parse(response["Location"]).query).to be_nil
        end

        it "should only redirect to legacy url if no page was found for urlname" do
          alchemy_get :show, urlname: legacy_page.urlname
          expect(response.status).to eq(200)
          expect(response).not_to redirect_to("/#{page.urlname}")
        end

        it "should redirect to last page that has that legacy url" do
          expect(request).to receive(:fullpath).at_least(:once).and_return(legacy_url2.urlname)
          alchemy_get :show, urlname: legacy_url2.urlname
          expect(response).to redirect_to("/#{second_page.urlname}")
        end

        it "should redirect even if the url has get parameters" do
          expect(request).to receive(:fullpath).at_least(:once).and_return(legacy_url3.urlname)
          alchemy_get :show, urlname: legacy_url3.urlname
          expect(response).to redirect_to("/#{second_page.urlname}")
        end

        it "should redirect even if the url has nested urlname" do
          expect(request).to receive(:fullpath).at_least(:once).and_return(legacy_url5.urlname)
          alchemy_get :show, urlname: legacy_url5.urlname
          expect(response).to redirect_to("/#{second_page.urlname}")
        end
      end
    end

    describe "while redirecting" do
      context "not in multi language mode" do
        before do
          allow_any_instance_of(PagesController).to receive(:multi_language?).and_return(false)
        end

        context "with no lang parameter present" do
          it "should store defaults language id in the session." do
            alchemy_get :show, urlname: page.urlname
            expect(controller.session[:alchemy_language_id]).to eq(Language.default.id)
          end

          it "should store default language as class var." do
            alchemy_get :show, urlname: page.urlname
            expect(Language.current).to eq(Language.default)
          end
        end
      end
    end

    describe '#page_etag' do
      subject { controller.send(:page_etag) }

      before do
        expect(page).to receive(:cache_key).and_return('aaa')
        controller.instance_variable_set('@page', page)
      end

      it "returns the etag for response headers" do
        expect(subject).to eq('aaa')
      end

      context 'with user logged in' do
        before do
          authorize_user(mock_model(Alchemy.user_class, cache_key: 'bbb'))
        end

        it "returns another etag for response headers" do
          expect(subject).to eq('aaabbb')
        end
      end
    end

    describe '#cache_page?' do
      subject { controller.send(:cache_page?) }

      before do
        Rails.application.config.action_controller.perform_caching = true
        controller.instance_variable_set('@page', page)
      end

      it 'returns true when everthing is alright' do
        expect(subject).to be true
      end

      it 'returns false when the Rails app does not perform caching' do
        Rails.application.config.action_controller.perform_caching = false
        expect(subject).to be false
      end

      it 'returns false when there is no page' do
        controller.instance_variable_set('@page', nil)
        expect(subject).to be false
      end

      it 'returns false when caching is deactivated in the Alchemy config' do
        allow(Alchemy::Config).to receive(:get).with(:cache_pages).and_return(false)
        expect(subject).to be false
      end

      it 'returns false when the page layout is set to cache = false' do
        page_layout = PageLayout.get('news')
        page_layout['cache'] = false
        allow(PageLayout).to receive(:get).with('news').and_return(page_layout)
        expect(subject).to be false
      end

      it 'returns false when the page layout is set to searchresults = true' do
        page_layout = PageLayout.get('news')
        page_layout['searchresults'] = true
        allow(PageLayout).to receive(:get).with('news').and_return(page_layout)
        expect(subject).to be false
      end
    end
  end
end
