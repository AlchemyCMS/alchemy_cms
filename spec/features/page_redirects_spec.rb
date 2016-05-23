require 'spec_helper'

module Alchemy
  describe 'Requesting a page' do
    let!(:default_language) { Language.default }

    let!(:default_language_root) do
      create(:alchemy_page, :language_root, language: default_language, name: 'Home')
    end

    let(:public_page) do
      create(:alchemy_page, :public, visible: true, name: 'Page 1')
    end

    let(:public_child) do
      create(:alchemy_page, :public, name: 'Public Child', parent_id: public_page.id)
    end

    context "in multi language mode" do
      let(:second_page) { create(:alchemy_page, :public, name: 'Second Page') }

      let(:legacy_url) do
        LegacyPageUrl.create(
          urlname: 'index.php?option=com_content&view=article&id=48&Itemid=69',
          page: second_page
        )
      end

      before do
        allow_any_instance_of(PagesController).to receive(:multi_language?).and_return(true)
      end

      context 'if language params are given' do
        context "and page locale is default locale" do
          it "redirects to unprefixed locale url" do
            allow(::I18n).to receive(:default_locale) { public_page.language_code.to_sym }
            visit("/#{public_page.language_code}/#{public_page.urlname}")
            expect(page.current_path).to eq("/#{public_page.urlname}")
          end
        end

        context "and page locale is not default locale" do
          it "does not redirect" do
            allow(::I18n).to receive(:default_locale).and_return(:de)
            visit("/#{public_page.language_code}/#{public_page.urlname}")
            expect(page.current_path).to eq("/#{public_page.language_code}/#{public_page.urlname}")
          end
        end
      end

      context 'if no language params are given' do
        context "and page locale is default locale" do
          it "doesn't prepend the url with the locale string" do
            allow(::I18n).to receive(:default_locale) { public_page.language_code.to_sym }
            visit("/#{public_page.urlname}")
            expect(page.current_path).to eq("/#{public_page.urlname}")
          end

          it "redirects legacy url with unknown format & query string without locale prefix" do
            allow(::I18n).to receive(:default_locale) { second_page.language_code.to_sym }
            visit "/#{legacy_url.urlname}"
            uri = URI.parse(page.current_url)
            expect(uri.query).to be_nil
            expect(uri.request_uri).to eq("/#{second_page.urlname}")
          end
        end

        context "and page locale is not default locale" do
          before do
            allow(::I18n).to receive(:default_locale).and_return(:de)
          end

          it "redirects to url with the locale prefixed" do
            visit("/#{public_page.urlname}")
            expect(page.current_path).to eq("/en/#{public_page.urlname}")
          end

          it "redirects legacy url with unknown format & query string with locale prefix" do
            visit "/#{legacy_url.urlname}"
            uri = URI.parse(page.current_url)
            expect(uri.query).to be_nil
            expect(uri.request_uri).to eq("/en/#{second_page.urlname}")
          end
        end
      end

      context "if requested page is unpublished" do
        before do
          public_page.update_attributes(
            public_on: nil,
            visible: false,
            name: 'Not Public',
            urlname: ''
          )
          public_child
        end

        it "redirects to public child" do
          visit "/not-public"
          expect(page.current_path).to eq("/public-child")
        end

        context "with only unpublished pages in page tree" do
          before do
            public_child.update_attributes(public_on: nil)
          end

          it "should raise not found error" do
            expect {
              visit "/not-public"
            }.to raise_error(ActionController::RoutingError)
          end
        end

        context "if page locale is the default locale" do
          it "redirects to public child with prefixed locale" do
            allow(::I18n).to receive(:default_locale).and_return(:de)
            visit "/not-public"
            expect(page.current_path).to eq("/en/public-child")
          end
        end
      end

      context "if requested url is the index url" do
        context 'and redirect_index is set to true' do
          before do
            allow(Config).to receive(:get) do |arg|
              arg == :redirect_index ? true : Config.parameter(arg)
            end
            if Alchemy.version == "4.0.0.rc1"
              raise "Remove deprecated `redirect_index` configuration!"
            end
            ActiveSupport::Deprecation.silenced = true
          end

          after do
            ActiveSupport::Deprecation.silenced = false
          end

          context "and if page locale is the default locale" do
            it "redirects to the default language root page without prefixed locale" do
              visit '/'
              expect(page.current_path).to eq('/home')
            end

            context "having additional parameter" do
              it "redirects to the default language root page with prefixed locale while keeping the additional params" do
                visit '/?search=kitten'
                expect(page.current_url).to eq('http://www.example.com/home?search=kitten')
              end
            end
          end

          context "and if page locale is not the default locale" do
            before do
              allow(::I18n).to receive(:default_locale).and_return(:de)
            end

            it "redirects to the default language root page with prefixed locale" do
              visit '/'
              expect(page.current_path).to eq('/en/home')
            end

            context "having additional parameter" do
              it "redirects to the default language root page with prefixed locale while keeping the additional params" do
                visit '/?search=kitten'
                expect(page.current_url).to eq('http://www.example.com/en/home?search=kitten')
              end
            end
          end
        end

        context 'and redirect_index is set to false' do
          before do
            allow(Config).to receive(:get) do |arg|
              arg == :redirect_index ? false : Config.parameter(arg)
            end
          end

          it "does not redirect" do
            visit '/'
            expect(page.current_path).to eq('/')
          end
        end
      end

      context "if requested url is only the language code" do
        context 'and redirect_index is set to true' do
          before do
            allow(Config).to receive(:get) do |arg|
              arg == :redirect_index ? true : Config.parameter(arg)
            end
            if Alchemy.version == "4.0.0.rc1"
              raise "Remove deprecated `redirect_index` configuration!"
            end
            ActiveSupport::Deprecation.silenced = true
          end

          after do
            ActiveSupport::Deprecation.silenced = false
          end

          context "if page locale is the default locale" do
            it "redirects to pages url without locale prefixed" do
              visit "/#{default_language.code}"
              expect(page.current_path).to eq("/home")
            end
          end

          context "if page locale is not the default locale" do
            it "redirects to the default language root url with prefixed locale" do
              allow(::I18n).to receive(:default_locale).and_return(:de)
              visit "/#{default_language.code}"
              expect(page.current_path).to eq('/en/home')
            end
          end
        end

        context 'and redirect_index is set to false' do
          before do
            allow(Config).to receive(:get) do |arg|
              arg == :redirect_index ? false : Config.parameter(arg)
            end
          end

          context "if requested locale is the default locale" do
            before do
              allow(::I18n).to receive(:default_locale) { default_language.code }
            end

            it "redirects to '/'" do
              visit "/#{default_language.code}"
              expect(page.current_path).to eq('/')
            end
          end

          context "if page locale is not the default locale" do
            before do
              allow(::I18n).to receive(:default_locale) { :de }
            end

            it "does not redirect" do
              visit "/#{default_language.code}"
              expect(page.current_path).to eq("/#{default_language.code}")
            end
          end
        end
      end

      it "should keep additional params" do
        visit "/#{public_page.urlname}?query=Peter"
        expect(page.current_url).to match(/\?query=Peter/)
      end

      context "wrong language requested" do
        before do
          allow(Alchemy.user_class).to receive(:admins).and_return([1, 2])
        end

        it "should render 404 if urlname and lang parameter do not belong to same page" do
          create(:alchemy_language, :klingon)
          expect {
            visit "/kl/#{public_page.urlname}"
          }.to raise_error(ActionController::RoutingError)
        end

        it "should render 404 if requested language does not exist" do
          public_page
          LegacyPageUrl.delete_all
          expect {
            visit "/fo/#{public_page.urlname}"
          }.to raise_error(ActionController::RoutingError)
        end
      end
    end

    context "not in multi language mode" do
      let(:second_page) { create(:alchemy_page, :public, name: 'Second Page') }

      let(:legacy_url) do
        LegacyPageUrl.create(
          urlname: 'index.php?option=com_content&view=article&id=48&Itemid=69',
          page: second_page
        )
      end

      before do
        allow_any_instance_of(PagesController).to receive(:multi_language?).and_return(false)
      end

      it "redirects legacy url with unknown format & query string" do
        visit "/#{legacy_url.urlname}"
        uri = URI.parse(page.current_url)
        expect(uri.query).to be_nil
        expect(uri.request_uri).to eq("/#{second_page.urlname}")
      end

      it "redirects from nested language code url to normal url" do
        visit "/en/#{public_page.urlname}"
        expect(page.current_path).to eq("/#{public_page.urlname}")
      end

      context "redirects to public child" do
        before do
          public_page.update_attributes(
            visible: false,
            public_on: nil,
            name: 'Not Public',
            urlname: ''
          )
          public_child
        end

        it "if requested page is unpublished" do
          visit '/not-public'
          expect(page.current_path).to eq('/public-child')
        end

        it "with normal url, if requested url has nested language code and is not public" do
          visit '/en/not-public'
          expect(page.current_path).to eq('/public-child')
        end
      end

      context 'if requested url is index url' do
        context "when locale is prefixed" do
          it "redirects to normal url" do
            visit "/en"
            expect(page.current_path).to eq("/")
          end
        end

        context "when redirect_index is enabled" do
          before do
            allow(Config).to receive(:get) do |arg|
              arg == :redirect_index ? true : Config.parameter(arg)
            end
            if Alchemy.version == "4.0.0.rc1"
              raise "Remove deprecated `redirect_index` configuration!"
            end
          end

          it "redirects to pages url" do
            ActiveSupport::Deprecation.silence do
              visit '/'
              expect(page.current_path).to eq('/home')
            end
          end
        end
      end

      it "should keep additional params" do
        visit "/en/#{public_page.urlname}?query=Peter"
        expect(page.current_url).to match(/\?query=Peter/)
      end
    end
  end
end
