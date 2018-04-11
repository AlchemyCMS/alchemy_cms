# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Alchemy::PagesController, 'OnPageLayout mixin', type: :controller do
  routes { Alchemy::Engine.routes }

  before(:all) do
    ApplicationController.send(:extend, Alchemy::OnPageLayout)
  end

  let(:page) { create(:alchemy_page, :public, page_layout: 'standard') }

  describe '.on_page_layout' do
    context 'with :all as argument for page_layout' do
      before do
        ApplicationController.class_eval do
          on_page_layout(:all) do
            @on_all_layouts = @page.page_layout
          end
        end
      end

      context "for show action" do
        %w(standard news).each do |page_layout|
          it "runs callback on #{page_layout} layout" do
            page = create(:alchemy_page, :public, page_layout: page_layout)
            get :show, params: {urlname: page.urlname}
            expect(assigns(:on_all_layouts)).to eq(page_layout)
          end
        end
      end

      context "for index action" do
        %w(standard news).each do |page_layout|
          it "runs callback on #{page_layout} layout" do
            create(:alchemy_page, :language_root, page_layout: page_layout)

            get :index
            expect(assigns(:on_all_layouts)).to eq(page_layout)
          end
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
        context "for show action" do
          let(:page) { create(:alchemy_page, :public, page_layout: 'standard') }

          it 'runs the callback' do
            get :show, params: {urlname: page.urlname}
            expect(assigns(:successful_for_standard)).to eq(true)
          end
        end

        context "for index action" do
          let!(:page) { create(:alchemy_page, :language_root, page_layout: 'standard') }

          it 'runs the callback' do
            get :index
            expect(assigns(:successful_for_standard)).to eq(true)
          end
        end
      end

      context 'and page not having standard layout' do
        let(:page) { create(:alchemy_page, :public, page_layout: 'news') }

        context "for show action" do
          it "doesn't run the callback" do
            get :show, params: {urlname: page.urlname}
            expect(assigns(:successful_for_standard)).to eq(nil)
          end
        end

        context "for index action" do
          let!(:page) { create(:alchemy_page, :language_root, page_layout: 'news') }

          it "doesn't run the callback" do
            get :index
            expect(assigns(:successful_for_standard)).to eq(nil)
          end
        end
      end
    end

    context 'when defining two callbacks for different page layouts' do
      context "for show action" do
        before do
          ApplicationController.class_eval do
            on_page_layout(:standard) do
              @urlname = @page.urlname
            end

            on_page_layout(:news) do
              @urlname = @page.urlname
            end
          end
        end

        %w(standard news).each do |page_layout|
          it "runs both callbacks for #{page_layout} layout" do
            page = create(:alchemy_page, :public, page_layout: page_layout)

            get :show, params: {urlname: page.urlname}
            expect(assigns(:urlname)).to eq(page.urlname)
          end
        end
      end

      context "for index action" do
        before do
          ApplicationController.class_eval do
            on_page_layout(:standard) do
              @page_layout = @page.page_layout
            end

            on_page_layout(:news) do
              @page_layout = @page.page_layout
            end
          end
        end

        %w(standard news).each do |page_layout|
          it "runs both callbacks on #{page_layout} layout" do
            create(:alchemy_page, :language_root, page_layout: page_layout)

            get :index
            expect(assigns(:page_layout)).to eq(page_layout)
          end
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

      context "for show action" do
        it 'runs both callbacks' do
          get :show, params: {urlname: page.urlname}
          expect(assigns(:successful_for_standard_first)).to eq(true)
          expect(assigns(:successful_for_standard_second)).to eq(true)
        end
      end

      context "for index action" do
        let!(:page) { create(:alchemy_page, :language_root, page_layout: 'standard') }

        it 'runs both callbacks' do
          get :index
          expect(assigns(:successful_for_standard_first)).to eq(true)
          expect(assigns(:successful_for_standard_second)).to eq(true)
        end
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

      context 'for show action' do
        it 'evaluates the given block' do
          get :show, params: {urlname: page.urlname}
          expect(assigns(:successful_for_callback_method)).to eq(true)
        end
      end

      context 'for index action' do
        let!(:page) { create(:alchemy_page, :language_root, page_layout: 'standard') }

        it 'evaluates the given block' do
          get :index
          expect(assigns(:successful_for_callback_method)).to eq(true)
        end
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

      context 'for show action' do
        it 'runs the given callback method' do
          get :show, params: {urlname: page.urlname}
          expect(assigns(:successful_for_callback_method)).to eq(true)
        end
      end

      context 'for index action' do
        let!(:page) { create(:alchemy_page, :language_root, page_layout: 'standard') }

        it 'runs the given callback method' do
          get :index
          expect(assigns(:successful_for_callback_method)).to eq(true)
        end
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
            @successful = @page.page_layout
          end
        end
      end

      %w(standard news).each do |page_layout|
        it 'evaluates the given callback on both page_layouts for show action' do
          page = create(:alchemy_page, :public, page_layout: page_layout)

          get :show, params: {urlname: page.urlname}
          expect(assigns(:successful)).to eq(page_layout)
        end
      end

      %w(standard news).each do |page_layout|
        it 'evaluates the given callback on both page_layouts for index action' do
          create(:alchemy_page, :language_root, page_layout: page_layout)

          get :index
          expect(assigns(:successful)).to eq(page_layout)
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
      head :ok
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
  routes { Alchemy::Engine.routes }

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

    context "for show action" do
      let(:page) { create(:alchemy_page, page_layout: 'standard') }

      it 'callback also runs' do
        get :show, params: {id: page.id}
        expect(assigns(:successful_for_alchemy_admin_pages_controller)).to be(true)
      end
    end

    context "for index action" do
      it 'does not run callback' do
        get :index
        expect(assigns(:successful_for_alchemy_admin_pages_controller)).to be(nil)
      end
    end
  end

  after(:all) do
    Alchemy::OnPageLayout.instance_variable_set(:@callbacks, nil)
  end
end
