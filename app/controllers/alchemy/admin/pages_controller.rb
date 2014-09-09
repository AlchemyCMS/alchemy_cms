require 'handles_sortable_columns'

module Alchemy
  module Admin
    class PagesController < Alchemy::Admin::BaseController
      helper 'alchemy/pages'

      before_action :set_translation,
        except: [:show]

      before_action :load_page,
        only: [:show, :info, :unlock, :visit, :publish, :configure, :edit, :update, :destroy]

      before_action :reject_editing,
        only: [:edit],
        if: -> { page_is_locked? }

      before_action :load_locked_pages,
        only: [:index, :edit]

      authorize_resource class: Alchemy::Page

      # Needs to be included after +before_action+ calls, to be sure the filters are appended.
      include OnPageLayout::CallbacksRunner

      # Lists all pages
      #
      def index
        @pages = Language.current.pages
        @pages = @pages.page(params[:page] || 1).per(per_page_value_for_screen_size)
      end

      # Used by page preview iframe in Page#edit view.
      #
      def show
        @preview_mode = true
        Page.current_preview = @page
        # Setting the locale to pages language, so the page content has it's correct translations.
        ::I18n.locale = @page.language_code
        render layout: 'application'
      end

      # Displays information of this page
      #
      def info
        render layout: !request.xhr?
      end

      # Displays a form for creating a new page
      #
      def new
        @page = Page.new(
          language: Language.current,
          parent_id: params[:parent_id],
          create_node: true
        )
        @parents = Language.current.pages
        @page_layouts = PageLayout.layouts_for_select(Language.current.id, @page.layoutpage?)
        @clipboard = get_clipboard('pages')
        @clipboard_items = Page.all_from_clipboard_for_select(@clipboard, Language.current.id, @page.layoutpage?)
      end

      def create
        @page = paste_from_clipboard || Page.new(page_params)
        if @page.save
          flash[:notice] = _t("Page created", name: @page.name)
          do_redirect_to(redirect_path_after_create_page)
        else
          @parents = Language.current.pages
          @page_layouts = PageLayout.layouts_for_select(Language.current.id, @page.layoutpage?)
          @clipboard = get_clipboard('pages')
          @clipboard_items = Page.all_from_clipboard_for_select(@clipboard, Language.current.id, @page.layoutpage?)
          render :new
        end
      end

      # Edit the content of the page and all its elements and contents.
      #
      # If the page is locked by another user editing is rejected.
      #
      def edit
        @page.lock_to!(current_alchemy_user)
        @layoutpage = @page.layoutpage?
      end

      # Set page configuration like page names, meta tags and states.
      def configure
        @parents = Language.current.pages.where.not(id: @page.id)
        @page_layouts = PageLayout.layouts_with_own_for_select(@page.page_layout, Language.current.id, @page.layoutpage?)
      end

      # Updates page
      #
      # * fetches page via before filter
      #
      def update
        # stores old page_layout value, because unfurtunally rails @page.changes does not work here.
        @old_page_layout = @page.page_layout
        if @page.update(page_params)
          @notice = _t('Page saved', name: @page.name)
          @while_page_edit = request.referer.include?('edit')
          respond_to do |format|
            format.html { redirect_to admin_pages_path }
            format.js { render }
          end
        else
          configure
        end
      end

      def destroy
        # fetching page via before filter
        name = @page.name
        @page_id = @page.id
        @layoutpage = @page.layoutpage?
        if @page.destroy
          @message = _t('Page deleted', name: name)
          flash[:notice] = @message
          respond_to do |format|
            format.js
          end
          # remove from clipboard
          @clipboard = get_clipboard('pages')
          @clipboard.delete_if { |item| item['id'] == @page_id.to_s }
        end
      end

      def link
        @content_id = params[:content_id]
        @attachments = Attachment.all.map do |f|
          [f.name, download_attachment_path(id: f.id, name: f.urlname)]
        end
        if multi_language?
          @url_prefix = "#{Language.current.code}/"
        end
      end

      # Leaves the page editing mode and unlocks the page for other users
      def unlock
        # fetching page via before filter
        @page.unlock!
        flash[:notice] = _t(:unlocked_page, :name => @page.name)
        @pages_locked_by_user = Page.from_current_site.locked_by(current_alchemy_user)
        respond_to do |format|
          format.js
          format.html {
            redirect_to params[:redirect_to].blank? ? admin_pages_path : params[:redirect_to]
          }
        end
      end

      def visit
        @page.unlock!
        redirect_to show_page_path(urlname: @page.urlname, locale: multi_language? ? @page.language_code : nil)
      end

      # Sets the page public and updates the published_at attribute that is used as cache_key
      #
      def publish
        # fetching page via before filter
        @page.publish!
        flash[:notice] = _t(:page_published, :name => @page.name)
        redirect_back_or_to_default(admin_pages_path)
      end

      def flush
        Language.current.pages.flushables.update_all(published_at: Time.current)
        # We need to ensure, that also all layoutpages get the +published_at+ timestamp set,
        # but not set to public true, because the cache_key for an element is +published_at+
        # and we don't want the layout pages to be present in +Page.published+ scope.
        # Not the greatest solution, but ¯\_(ツ)_/¯
        Language.current.pages.flushable_layoutpages.update_all(published_at: Time.current)
        respond_to { |format| format.js }
      end

      def switch_language
        set_alchemy_language(params[:language_id])
        do_redirect_to redirect_path_for_switch_language
      end

      private

      def reject_editing
        flash[:notice] = _t('This page is locked', name: @page.locker_name)
        redirect_to admin_pages_path
      end

      def load_page
        @page = Page.find(params[:id])
      end

      def load_locked_pages
        @locked_pages = Page.from_current_site.all_locked_by(current_alchemy_user)
      end

      def redirect_path_after_create_page
        params[:redirect_to] || edit_admin_page_path(@page)
      end

      def page_params
        params.require(:page).permit(*secure_attributes)
      end

      def secure_attributes
        Page::PERMITTED_ATTRIBUTES
      end

      def page_is_locked?
        return false if !@page.locker.try(:logged_in?)
        return false if !current_alchemy_user.respond_to?(:id)
        @page.locked? && @page.locker.id != current_alchemy_user.id
      end

      def paste_from_clipboard
        if params[:paste_from_clipboard]
          source = Page.find(params[:paste_from_clipboard])
          parent = Page.find_by(id: params[:page][:parent_id]) || Page.root
          Page.copy_and_paste(source, parent, params[:page][:name])
        end
      end

      def redirect_path_for_switch_language
        if request.referer && request.referer.include?('admin/layoutpages')
          admin_layoutpages_path
        else
          admin_pages_path
        end
      end
    end
  end
end
