require 'spec_helper'

RSpec.describe Alchemy::PagesController, 'OnPageLayout mixin', type: :controller do
  before(:all) do
    ApplicationController.send(:extend, Alchemy::OnPageLayout)
  end

  let(:page)     { create(:alchemy_page, :public, page_layout: 'standard') }
  let(:page_two) { create(:alchemy_page, :public, page_layout: 'news') }

  describe '.on_page_layout' do
    context 'with :all as argument for page_layout' do
      before do
        ApplicationController.class_eval do
          on_page_layout(:all) do
            @urlname = params[:urlname]
          end
        end
      end

      it 'runs on all page layouts' do
        [page, page_two].each do |p|
          alchemy_get :show, urlname: p.urlname
          expect(assigns(:urlname)).to eq(p.urlname)
        end
      end
    end

    context 'with :standard as argument for page_layout' do
      before do
        ApplicationController.class_eval do
          on_page_layout(:standard) do
            @successful_for_standard = true
          end
        end
      end

      context 'and page having standard layout' do
        it 'runs the callback' do
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:successful_for_standard)).to eq(true)
        end
      end

      context 'and page not having standard layout' do
        let(:page) { create(:alchemy_page, :public, page_layout: 'news') }

        it "doesn't run the callback" do
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:successful_for_standard)).to eq(nil)
        end
      end
    end

    context 'when defining two callbacks for different page_layouts' do
      before do
        ApplicationController.class_eval do
          on_page_layout(:standard) do
            @urlname = params[:urlname]
          end

          on_page_layout(:news) do
            @urlname = params[:urlname]
          end
        end
      end

      it 'runs both callbacks' do
        [:standard, :news].each do |page_layout|
          page = create(:alchemy_page, :public, page_layout: page_layout)
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:urlname)).to eq(page.urlname)
        end
      end
    end

    context 'when defining two callbacks for the same page_layout' do
      before do
        ApplicationController.class_eval do
          on_page_layout(:standard) do
            @successful_for_standard_first = true
          end

          on_page_layout(:standard) do
            @successful_for_standard_second = true
          end
        end
      end

      it 'runs both callbacks' do
        alchemy_get :show, urlname: page.urlname
        expect(assigns(:successful_for_standard_first)).to eq(true)
        expect(assigns(:successful_for_standard_second)).to eq(true)
      end
    end

    context 'when block is given' do
      before do
        ApplicationController.class_eval do
          on_page_layout :standard do
            @successful_for_callback_method = true
          end
        end
      end

      it 'evaluates the given block' do
        alchemy_get :show, urlname: page.urlname
        expect(assigns(:successful_for_callback_method)).to eq(true)
      end
    end

    context 'when callback method name is given' do
      before do
        ApplicationController.class_eval do
          on_page_layout :standard, :run_method

          def run_method
            @successful_for_callback_method = true
          end
        end
      end

      it 'runs the given callback method' do
        alchemy_get :show, urlname: page.urlname
        expect(assigns(:successful_for_callback_method)).to eq(true)
      end
    end

    context 'when neither callback method name nor block given' do
      it 'raises an ArgumentError' do
        expect do
          ApplicationController.class_eval do
            on_page_layout :standard
          end
        end.to raise_error(ArgumentError)
      end
    end

    context 'when passing two page_layouts for a callback' do
      before do
        ApplicationController.class_eval do
          on_page_layout([:standard, :news]) do
            @successful = true
          end
        end
      end

      it 'evaluates the given callback on both page_layouts' do
        [page, page_two].each do |page|
          alchemy_get :show, urlname: page.urlname
          expect(assigns(:successful)).to eq(true)
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
      expect(assigns(:another_controller)).to eq(true)
      expect(assigns(:successful_for_another_controller)).to eq(nil)
    end
  end
end

RSpec.describe Alchemy::Admin::PagesController, 'OnPageLayout mixin', type: :controller do
  before(:all) do
    ApplicationController.send(:extend, Alchemy::OnPageLayout)
  end

  context 'in admin/pages_controller' do
    before do
      ApplicationController.class_eval do
        on_page_layout(:standard) do
          @successful_for_alchemy_admin_pages_controller = true
        end
      end
      authorize_user(:as_admin)
    end

    let(:page) { create(:alchemy_page, page_layout: 'standard') }

    it 'callback also runs' do
      alchemy_get :show, id: page.id
      expect(assigns(:successful_for_alchemy_admin_pages_controller)).to be(true)
    end
  end
end
