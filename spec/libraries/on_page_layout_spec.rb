require 'spec_helper'

RSpec.describe Alchemy::PagesController, 'OnPageLayout mixin', type: :controller do
  before(:all) do
    ApplicationController.send(:extend, Alchemy::OnPageLayout)
  end

  let(:page) { create(:public_page, page_layout: 'standard') }

  describe 'defines .on_page_layout class method' do
    context 'with :all as parameter' do
      context 'and block given' do
        before do
          ApplicationController.class_eval do
            on_page_layout(:all) do
              @successful_for_all = true
              @the_page_instance = @page
            end
          end
        end

        it 'runs on all page layouts' do
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:successful_for_all)).to be_truthy
        end

        it 'has @page instance' do
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:the_page_instance)).to eq(page)
        end
      end

      context 'and method name instead of block given' do
        before do
          ApplicationController.class_eval do
            on_page_layout :all, :my_all_callback_method

            def my_all_callback_method
              @successful_for_all_callback_method = true
              @the_all_page_instance = @page
            end
          end
        end

        it 'runs on all page layouts' do
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:successful_for_all_callback_method)).to be_truthy
        end

        it 'has @page instance' do
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:the_all_page_instance)).to eq(page)
        end
      end
    end

    context 'with :standard as parameter' do
      before do
        ApplicationController.class_eval do
          on_page_layout(:standard) do
            @successful_for_standard = true
          end
        end
      end

      context 'and page having standard layout' do
        it 'runs callback' do
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:successful_for_standard)).to be_truthy
        end
      end

      context 'and page not having standard layout' do
        let(:page) { create(:public_page, page_layout: 'news') }

        it "doesn't run callback" do
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:successful_for_standard)).to be_falsey
        end
      end
    end
  end
end

RSpec.describe ApplicationController, 'OnPageLayout mixin', type: :controller do
  before(:all) do
    ApplicationController.send(:extend, Alchemy::OnPageLayout)
  end

  controller do
    def index
      @another_controller = true
      render nothing: true
    end
  end

  context 'in another controller' do
    before do
      ApplicationController.class_eval do
        on_page_layout(:standard) do
          @successful_for_another_controller = true
        end
      end
    end

    it 'callback does not run' do
      get :index
      expect(assigns(:another_controller)).to be_truthy
      expect(assigns(:successful_for_another_controller)).to be_falsey
    end
  end
end
