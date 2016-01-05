require 'ostruct'
require 'spec_helper'

module Alchemy
  describe PagesController do
    let(:default_language)      { Language.default }
    let(:default_language_root) { create(:alchemy_page, :language_root, language: default_language, name: 'Home', public: true) }
    let(:page) { create(:alchemy_page, :public, parent_id: default_language_root.id, page_layout: 'news', name: 'News', urlname: 'news', language: default_language, do_not_autogenerate: false) }

    before { allow(controller).to receive(:signup_required?).and_return(false) }

    describe "#index" do
      before do
        default_language_root
        allow(Config).to receive(:get) do |arg|
          arg == :redirect_index ? false : Config.parameter(arg)
        end
      end

      it 'renders :show template' do
        expect(alchemy_get(:index)).to render_template(:show)
      end

      context 'requesting nothing' do
        it 'loads default language root page' do
          alchemy_get :index
          expect(assigns(:page)).to eq(default_language_root)
        end

        it 'sets @root_page to default language root' do
          alchemy_get(:index)
          expect(assigns(:root_page)).to eq(default_language_root)
        end

        context 'and the root page is not public' do
          before do
            default_language_root.update!(public: false)
          end

          context 'and redirect_to_public_child is set to false' do
            before do
              allow(Config).to receive(:get) do |arg|
                arg == :redirect_to_public_child ? false : Config.parameter(arg)
              end
            end

            it 'raises routing error (404)' do
              expect {
                alchemy_get :index
              }.to raise_error(ActionController::RoutingError)
            end
          end

          context 'and redirect_to_public_child is set to true' do
            before do
              allow(Config).to receive(:get) do |arg|
                arg == :redirect_to_public_child ? true : Config.parameter(arg)
              end
            end

            context 'that has a public child' do
              let!(:public_child) do
                create(:alchemy_page, :public, parent: default_language_root)
              end

              it 'loads this page' do
                alchemy_get :index
                expect(assigns(:page)).to eq(public_child)
              end
            end

            context 'that has a non public child' do
              let!(:non_public_child) do
                create(:alchemy_page, parent: default_language_root)
              end

              context 'that has a public child' do
                let!(:public_child) do
                  create(:alchemy_page, :public, parent: non_public_child)
                end

                it 'loads this page' do
                  alchemy_get :index
                  expect(assigns(:page)).to eq(public_child)
                end
              end

              context 'that has a non public child' do
                before do
                  create(:alchemy_page, parent: non_public_child)
                end

                it 'raises routing error (404)' do
                  expect {
                    alchemy_get :index
                  }.to raise_error(ActionController::RoutingError)
                end
              end
            end
          end
        end
      end

      context 'requesting non default locale' do
        let!(:deutsch) do
          create(:alchemy_language, name: 'Deutsch', code: 'de', default: false)
        end

        let!(:startseite) do
          create :alchemy_page, :language_root,
            language: deutsch, public: true, name: 'Startseite'
        end

        before do
          allow(::I18n).to receive(:default_locale) { 'en' }
        end

        it 'loads the root page of that language' do
          alchemy_get :index, locale: 'de'
          expect(assigns(:page)).to eq(startseite)
        end

        it 'sets @root_page to root page of that language' do
          alchemy_get :index, locale: 'de'
          expect(assigns(:root_page)).to eq(startseite)
        end
      end
    end

    context 'an author' do
      let(:unpublic) { create(:alchemy_page, parent: default_language_root) }

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

      let(:catalog)  { create(:alchemy_page, :public, name: "Catalog", urlname: 'catalog', parent: default_language_root, language: default_language, visible: true) }
      let(:products) { create(:alchemy_page, :public, name: "Products", urlname: 'products', parent: catalog, language: default_language, visible: true) }
      let(:product)  { create(:alchemy_page, :public, name: "Screwdriver", urlname: 'screwdriver', parent: products, language: default_language, do_not_autogenerate: false, visible: true) }

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

    describe 'Redirecting to legacy page urls' do
      context 'Request a page with legacy url' do
        let(:page)        { create(:alchemy_page, :public, name: 'New page name') }
        let(:second_page) { create(:alchemy_page, :public, name: 'Second Page') }
        let(:legacy_page) { create(:alchemy_page, :public, name: 'Legacy Url') }
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
