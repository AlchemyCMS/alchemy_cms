# frozen_string_literal: true

module Alchemy
  module Admin
    class PagesController < ResourcesController
      include OnPageLayout::CallbacksRunner

      helper "alchemy/pages"

      before_action :load_resource, except: [:index, :flush, :new, :create, :copy_language_tree, :link]

      authorize_resource class: Alchemy::Page, except: [:index, :tree]

      before_action only: [:index, :tree, :flush, :new, :create, :copy_language_tree] do
        authorize! :index, :alchemy_admin_pages
      end

      include Alchemy::Admin::CurrentLanguage

      before_action :set_translation,
        except: [:show]

      before_action :set_root_page,
        only: [:index, :show]

      before_action :set_preview_mode, only: [:show]

      before_action :load_languages_and_layouts,
        unless: -> { @page_root },
        only: [:index]

      before_action :set_view, only: [:index, :update]

      before_action :set_page_version, only: [:show, :edit]

      before_action :run_on_page_layout_callbacks,
        if: :run_on_page_layout_callbacks?,
        only: [:show]

      def index
        @query = @current_language.pages.contentpages.ransack(search_filter_params[:q])

        if @view == "list"
          @query.sorts = default_sort_order if @query.sorts.empty?
          items = @query.result

          if search_filter_params[:tagged_with].present?
            items = items.tagged_with(search_filter_params[:tagged_with])
          end

          if search_filter_params[:filter].present?
            items = apply_filters(items)
          end

          items = items.page(params[:page] || 1).per(items_per_page)
          @pages = items
        end
      end

      # Returns all pages as a tree from the root given by the id parameter
      #
      def tree
        render json: serialized_page_tree
      end

      # Used by page preview iframe in Page#edit view.
      #
      def show
        Current.preview_page = @page
        # Setting the locale to pages language, so the page content has it's correct translations.
        ::I18n.locale = @page.language.locale
        render(layout: Alchemy::Config.get(:admin_page_preview_layout) || "application")
      end

      def info
        render layout: !request.xhr?
      end

      def new
        @page ||= Page.new(layoutpage: params[:layoutpage] == "true", parent_id: params[:parent_id])
        @page_layouts = Page.layouts_for_select(@current_language.id, layoutpages: @page.layoutpage?)
        @clipboard = get_clipboard("pages")
        @clipboard_items = Page.all_from_clipboard_for_select(@clipboard, @current_language.id, layoutpages: @page.layoutpage?)
      end

      def create
        @page = paste_from_clipboard || Page.new(page_params)
        if @page.save
          flash[:notice] = Alchemy.t("Page created", name: @page.name)
          do_redirect_to(redirect_path_after_create_page)
        else
          new
          render :new
        end
      end

      # Edit the content of the page and all its elements and ingredients.
      #
      # Locks the page to current user to prevent other users from editing it meanwhile.
      #
      def edit
        # fetching page via before filter
        if page_is_locked?
          flash[:warning] = Alchemy.t("This page is locked", name: @page.locker_name)
          redirect_to admin_pages_path
        elsif page_needs_lock?
          @page.lock_to!(current_alchemy_user)
        end
        @preview_urls = Alchemy.preview_sources.map do |klass|
          [
            klass.model_name.human,
            klass.new(routes: Alchemy::Engine.routes).url_for(@page)
          ]
        end
        @preview_url = @preview_urls.first.last
        @layoutpage = @page.layoutpage?
        Alchemy::Current.language = @page.language
      end

      # Set page configuration like page names, meta tags and states.
      def configure
      end

      # Updates page
      #
      # * fetches page via before filter
      #
      def update
        @old_parent_id = @page.parent_id
        if @page.update(page_params)
          @notice = Alchemy.t("Page saved", name: @page.name)
          @while_page_edit = request.referer.include?("edit")

          if @view == "list"
            flash[:notice] = @notice
          end

          unless @while_page_edit
            @tree = serialized_page_tree
          end
        else
          render :configure, status: :unprocessable_entity
        end
      end

      # Fetches page via before filter, destroys it and redirects to page tree
      def destroy
        if @page.destroy
          flash[:notice] = Alchemy.t("Page deleted", name: @page.name)

          # Remove page from clipboard
          clipboard = get_clipboard("pages")
          clipboard.delete_if { |item| item["id"] == @page.id.to_s }
        else
          flash[:warning] = @page.errors.full_messages.to_sentence
        end

        respond_to do |format|
          format.js do
            @redirect_url = if @page.layoutpage?
              alchemy.admin_layoutpages_path
            else
              alchemy.admin_pages_path
            end

            render :redirect
          end
        end
      end

      def link
        render LinkDialog::Tabs.new(**link_dialog_params)
      end

      def fold
        # @page is fetched via before filter
        @page.fold!(current_alchemy_user.id, !@page.folded?(current_alchemy_user.id))
        render json: serialized_page_tree
      end

      # Leaves the page editing mode and unlocks the page for other users
      def unlock
        # fetching page via before filter
        @page.unlock!
        flash[:notice] = Alchemy.t(:unlocked_page, name: @page.name)
        @pages_locked_by_user = Page.from_current_site.locked_by(current_alchemy_user)
        respond_to do |format|
          format.js
          format.html do
            redirect_to(unlock_redirect_path, allow_other_host: true)
          end
        end
      end

      def unlock_redirect_path
        if params[:redirect_to].to_s.match?(/\A\/admin\/(layout_)?pages/)
          params[:redirect_to]
        else
          admin_pages_path
        end
      end

      # Sets the page public and updates the published_at attribute that is used as cache_key
      #
      def publish
        # fetching page via before filter
        @page.publish!

        flash[:notice] = Alchemy.t(:page_published, name: @page.name)
        redirect_back(fallback_location: admin_pages_path)
      end

      def copy_language_tree
        language_root_to_copy_from.copy_children_to(copy_of_language_root)
        flash[:notice] = Alchemy.t(:language_pages_copied)
        redirect_to admin_pages_path
      end

      def flush
        @current_language.pages.flushables.update_all(published_at: Time.current)
        # We need to ensure, that also all layoutpages get the +published_at+ timestamp set,
        # but not set to public true, because the cache_key for an element is +published_at+
        # and we don't want the layout pages to be present in +Page.published+ scope.
        @current_language.pages.flushable_layoutpages.update_all(published_at: Time.current)
        respond_to { |format| format.js }
      end

      private

      def resource_handler
        @_resource_handler ||= Alchemy::Resource.new(controller_path, alchemy_module, Alchemy::Page)
      end

      def set_view
        @view = params[:view] || session[:alchemy_pages_view] || "tree"
        session[:alchemy_pages_view] = @view
      end

      def copy_of_language_root
        Page.copy(
          language_root_to_copy_from,
          language_id: params[:languages][:new_lang_id],
          language_code: @current_language.code
        )
      end

      def language_root_to_copy_from
        Page.language_root_for(params[:languages][:old_lang_id])
      end

      # Returns a pair, the path that a given tree node should take, and the path its children should take
      #
      # This function will add a node's own slug into their ancestor's path
      # in order to create the full URL of a node
      #
      # @param [String]
      #   The node's ancestors path
      # @param [Hash]
      #   A children node
      #
      def process_url(ancestors_path, item)
        default_urlname = (ancestors_path.blank? ? "" : "#{ancestors_path}/") + item["slug"].to_s
        {my_urlname: default_urlname, children_path: default_urlname}
      end

      def load_resource
        @page = Page.includes(page_includes).find(params[:id])
      end

      def pages_from_raw_request
        request.raw_post.split("&").map do |i|
          parts = i.split("=")
          {
            parts[0].gsub(/[^0-9]/, "") => parts[1]
          }
        end
      end

      def redirect_path_after_create_page
        if @page.editable_by?(current_alchemy_user)
          params[:redirect_to] || edit_admin_page_path(@page)
        else
          admin_pages_path
        end
      end

      def page_params
        params.require(:page).permit(*secure_attributes)
      end

      def link_dialog_params
        params.permit([:url, :selected_tab, :link_title, :link_target])
      end

      def secure_attributes
        if can?(:create, Alchemy::Page)
          Page::PERMITTED_ATTRIBUTES + [:language_root, :parent_id, :language_id, :language_code]
        else
          Page::PERMITTED_ATTRIBUTES
        end
      end

      def page_is_locked?
        return false if !@page.locker.try(:logged_in?)
        return false if !current_alchemy_user.respond_to?(:id)

        @page.locked? && @page.locker.id != current_alchemy_user.id
      end

      def page_needs_lock?
        return true unless @page.locker

        @page.locker.try!(:id) != current_alchemy_user.try!(:id)
      end

      def paste_from_clipboard
        if params[:paste_from_clipboard]
          source = Page.find(params[:paste_from_clipboard])
          parent = Page.find_by(id: params[:page][:parent_id])
          Page.copy_and_paste(source, parent, params[:page][:name])
        end
      end

      def set_root_page
        @page_root = @current_language.root_page
      end

      def set_page_version
        @page_version = @page.draft_version
      end

      def serialized_page_tree
        PageTreeSerializer.new(
          @page,
          ability: current_ability,
          user: current_alchemy_user
        )
      end

      def load_languages_and_layouts
        @language = @current_language
        @languages_with_page_tree = Language.on_current_site.with_root_page
        @page_layouts = Page.layouts_for_select(@language.id)
      end

      def set_preview_mode
        @preview_mode = true
      end

      def page_includes
        Alchemy::EagerLoading.page_includes(version: :draft_version)
      end
    end
  end
end
