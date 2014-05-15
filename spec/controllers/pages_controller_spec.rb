require 'ostruct'
require 'spec_helper'

module Alchemy
  describe PagesController do
    let(:default_language)      { Language.default }
    let(:default_language_root) { FactoryGirl.create(:language_root_page, language: default_language, name: 'Home', public: true) }
    let(:page) { FactoryGirl.create(:public_page, parent_id: default_language_root.id, page_layout: 'news', name: 'News', urlname: 'news', language: default_language, do_not_autogenerate: false) }

    before { controller.stub(:signup_required?).and_return(false) }

    context 'an author' do
      let(:unpublic) { create(:page, parent: default_language_root) }

      before { controller.stub(current_alchemy_user: author_user) }

      it "should not be able to visit a unpublic page" do
        get :show, urlname: unpublic.urlname
        response.status.should == 404
      end
    end

    context "requested for a page containing a feed" do
      render_views

      it "should render a rss feed" do
        get :show, urlname: page.urlname, format: :rss
        response.content_type.should == 'application/rss+xml'
      end

      it "should include content" do
        page.elements.first.content_by_name('news_headline').essence.update_attributes({body: 'Peters Petshop'})
        get :show, urlname: 'news', format: :rss
        response.body.should match /Peters Petshop/
      end
    end

    context "requested for a page that does not contain a feed" do
      it "should render xml 404 error" do
        get :show, urlname: default_language_root.urlname, format: :rss
        response.status.should == 404
      end
    end

    describe "Layout rendering" do
      context "with ajax request" do
        it "should not render a layout" do
          xhr :get, :show, urlname: page.urlname
          response.should render_template(:show)
          response.should_not render_template(layout: 'application')
        end
      end
    end

    describe "url nesting" do
      render_views

      let(:catalog)  { FactoryGirl.create(:public_page, name: "Catalog", urlname: 'catalog', parent: default_language_root, language: default_language, visible: true) }
      let(:products) { FactoryGirl.create(:public_page, name: "Products", urlname: 'products', parent: catalog, language: default_language, visible: true) }
      let(:product)  { FactoryGirl.create(:public_page, name: "Screwdriver", urlname: 'screwdriver', parent: products, language: default_language, do_not_autogenerate: false, visible: true) }

      before do
        Alchemy.user_class.stub(:admins).and_return(OpenStruct.new(count: 1))
        Config.stub(:get) { |arg| arg == :url_nesting ? true : false }
        product.elements.find_by_name('article').contents.essence_texts.first.essence.update_column(:body, 'screwdriver')
      end

      context "with correct levelnames in params" do
        it "should show the requested page" do
          get :show, {urlname: 'catalog/products/screwdriver'}
          response.status.should == 200
          response.body.should have_content("screwdriver")
        end
      end

      context "with incorrect levelnames in params" do
        it "should render a 404 page" do
          get :show, {urlname: 'catalog/faqs/screwdriver'}
          response.status.should == 404
          response.body.should have_content('The page you were looking for doesn\'t exist')
        end
      end
    end

    context "when a non-existent page is requested" do
      it "should rescue a RoutingError with rendering a 404 page." do
        get :show, {urlname: 'doesntexist'}
        response.status.should == 404
        response.body.should have_content('The page you were looking for doesn\'t exist')
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
            controller.should_receive(:redirect_page)
            controller.send(:redirect_to_public_child)
            controller.instance_variable_get('@page').should == public_page
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

        it "should redirect permanently to page that belongs to legacy page url." do
          get :show, urlname: legacy_url.urlname
          response.status.should == 301
          response.should redirect_to("/#{page.urlname}")
        end

        it "should only redirect to legacy url if no page was found for urlname" do
          get :show, urlname: legacy_page.urlname
          response.status.should == 200
          response.should_not redirect_to("/#{page.urlname}")
        end

        it "should redirect to last page that has that legacy url" do
          get :show, urlname: legacy_url2.urlname
          response.should redirect_to("/#{second_page.urlname}")
        end

        it "should redirect even if the url has get parameters" do
          get :show, urlname: legacy_url3.urlname
          response.should redirect_to("/#{second_page.urlname}")
        end
      end
    end

    describe "while redirecting" do
      context "not in multi language mode" do
        before do
          PagesController.any_instance.stub(:multi_language?).and_return(false)
        end

        context "with no lang parameter present" do
          it "should store defaults language id in the session." do
            get :show, urlname: 'a-public-page'
            controller.session[:alchemy_language_id].should == Language.default.id
          end

          it "should store default language as class var." do
            get :show, urlname: 'a-public-page'
            Language.current.should == Language.default
          end
        end
      end
    end

    describe '#page_etag' do
      subject { controller.send(:page_etag) }

      before do
        page.stub(cache_key: 'aaa')
        controller.instance_variable_set('@page', page)
      end

      it "returns the etag for response headers" do
        expect(subject).to eq('aaa')
      end

      context 'with user logged in' do
        let(:author_user) { mock_model(Alchemy.user_class, cache_key: 'bbb') }

        before do
          sign_in(author_user)
        end

        it "returns another etag for response headers" do
          expect(subject).to eq('aaabbb')
        end
      end
    end
  end
end
