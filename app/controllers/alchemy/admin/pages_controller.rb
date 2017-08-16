# frozen_string_literal: true

module Alchemy
  module Admin
    class PagesController < Alchemy::Admin::BaseController
      include OnPageLayout::CallbacksRunner

      helper 'alchemy/pages'

      before_action :set_translation,
        except: [:show]

      before_action :load_page,
        only: [:show, :info, :unlock, :visit, :publish, :configure, :edit, :update, :destroy, :fold,
               :tree]

      before_action :set_root_page,
        only: [:index, :show, :sort, :order]

      authorize_resource class: Alchemy::Page, except: [:index, :tree]

      before_action :run_on_page_layout_callbacks,
        if: :run_on_page_layout_callbacks?,
        only: [:show]

      def index
        authorize! :index, :alchemy_admin_pages

        @languages = Language.on_current_site
        if !@page_root
          @language = Language.current
          @languages_with_page_tree = Language.on_current_site.with_root_page
          @page_layouts = PageLayout.layouts_for_select(@language.id)
        end
      end

      # Returns all pages as a tree from the root given by the id parameter
      #
      def tree
        authorize! :tree, :alchemy_admin_pages

        render json: serialized_page_tree
      end

      # Used by page preview iframe in Page#edit view.
      #
      def show
        @preview_mode = true
        Page.current_preview = @page
        # Setting the locale to pages language, so the page content has it's correct translations.
        ::I18n.locale = @page.language.locale
        render layout: 'application'
      end

      def info
        render layout: !request.xhr?
      end

      def new
        @page = Page.new(layoutpage: params[:layoutpage] == 'true', parent_id: params[:parent_id])
        @page_layouts = PageLayout.layouts_for_select(Language.current.id, @page.layoutpage?)
        @clipboard = get_clipboard('pages')
        @clipboard_items = Page.all_from_clipboard_for_select(@clipboard, Language.current.id, @page.layoutpage?)
      end

      def create
        @page = paste_from_clipboard || Page.new(page_params)
        if @page.save
          flash[:notice] = Alchemy.t("Page created", name: @page.name)
          do_redirect_to(redirect_path_after_create_page)
        else
          @page_layouts = PageLayout.layouts_for_select(Language.current.id, @page.layoutpage?)
          @clipboard = get_clipboard('pages')
          @clipboard_items = Page.all_from_clipboard_for_select(@clipboard, Language.current.id, @page.layoutpage?)
          render :new
        end
      end

      # Edit the content of the page and all its elements and contents.
      #
      # Locks the page to current user to prevent other users from editing it meanwhile.
      #
      def edit
        # fetching page via before filter
        if page_is_locked?
          flash[:warning] = Alchemy.t('This page is locked', name: @page.locker_name)
          redirect_to admin_pages_path
        elsif page_needs_lock?
          @page.lock_to!(current_alchemy_user)
        end
        @layoutpage = @page.layoutpage?
      end

      # Set page configuration like page names, meta tags and states.
      def configure
        @page_layouts = PageLayout.layouts_with_own_for_select(@page.page_layout, Language.current.id, @page.layoutpage?)
        render @page.redirects_to_external? ? 'configure_external' : 'configure'
      end

      # Updates page
      #
      # * fetches page via before filter
      #
      def update
        # stores old page_layout value, because unfurtunally rails @page.changes does not work here.
        @old_page_layout = @page.page_layout
        if @page.update_attributes(page_params)
          @notice = Alchemy.t("Page saved", name: @page.name)
          @while_page_edit = request.referer.include?('edit')

          unless @while_page_edit
            @tree = serialized_page_tree
          end
        else
          configure
        end
      end

      # Fetches page via before filter, destroys it and redirects to page tree
      def destroy
        if @page.destroy
          flash[:notice] = Alchemy.t("Page deleted", name: @page.name)

          # Remove page from clipboard
          clipboard = get_clipboard('pages')
          clipboard.delete_if { |item| item['id'] == @page.id.to_s }
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
        if configuration(:show_real_root)
          @page_root = Page.root
        else
          set_root_page
        end
        @content_id = params[:content_id]
        @attachments = Attachment.all.collect { |f|
          [f.name, download_attachment_path(id: f.id, name: f.urlname)]
        }
        @url_prefix = prefix_locale? ? "#{Language.current.code}/" : ""
      end

      def fold
        # @page is fetched via before filter
        @page.fold!(current_alchemy_user.id, !@page.folded?(current_alchemy_user.id))
        respond_to do |format|
          format.js
        end
      end

      # Leaves the page editing mode and unlocks the page for other users
      def unlock
        # fetching page via before filter
        @page.unlock!
        flash[:notice] = Alchemy.t(:unlocked_page, name: @page.name)
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
        redirect_to show_page_url(
          urlname: @page.urlname,
          locale: prefix_locale? ? @page.language_code : nil,
          host: @page.site.host == "*" ? request.host : @page.site.host
        )
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

      def sort
        @sorting = true
      end

      # Receives a JSON object representing a language tree to be ordered
      # and updates all pages in that language structure to their correct indexes
      def order
        neworder = JSON.parse(params[:set])
        tree = create_tree(neworder, @page_root)

        Alchemy::Page.transaction do
          tree.each do |key, node|
            dbitem = Page.find(key)
            dbitem.update_node!(node)
          end
        end

        flash[:notice] = Alchemy.t("Pages order saved")
        do_redirect_to admin_pages_path
      end

      def switch_language
        set_alchemy_language(params[:language_id])
        do_redirect_to redirect_path_for_switch_language
      end

      def flush
        Language.current.pages.flushables.update_all(published_at: Time.current)
        # We need to ensure, that also all layoutpages get the +published_at+ timestamp set,
        # but not set to public true, because the cache_key for an element is +published_at+
        # and we don't want the layout pages to be present in +Page.published+ scope.
        Language.current.pages.flushable_layoutpages.update_all(published_at: Time.current)
        respond_to { |format| format.js }
      end

      private

      def copy_of_language_root
        page_copy = Page.copy(
          language_root_to_copy_from,
          language_id: params[:languages][:new_lang_id],
          language_code: Language.current.code
        )
        page_copy.move_to_child_of Page.root
        page_copy
      end

      def language_root_to_copy_from
        Page.language_root_for(params[:languages][:old_lang_id])
      end

      # Returns the current left index and the aggregated hash of tree nodes indexed by page id visited so far
      #
      # Visits a batch of children nodes, assigns them the correct ordering indexes and spuns recursively the same
      # procedure on their children, if any
      #
      # @param [Array]
      #   An array of children nodes to be visited
      # @param [Integer]
      #   The lft attribute that should be given to the first node in the array
      # @param [Integer]
      #   The page id of the parent of this batch of children nodes
      # @param [Integer]
      #   The depth at which these children reside
      # @param [Hash]
      #   A Hash of TreeNode's indexed by their page ids
      # @param [String]
      #   The url for the parent node of these children
      # @param [Boolean]
      #   Whether these children reside in a restricted branch according to their ancestors
      #
      def visit_nodes(nodes, my_left, parent, depth, tree, url, restricted)
        nodes.each do |item|
          my_right = my_left + 1
          my_restricted = item['restricted'] || restricted
          urls = process_url(url, item)

          if item['children']
            my_right, tree = visit_nodes(item['children'], my_left + 1, item['id'], depth + 1, tree, urls[:children_path], my_restricted)
          end

          tree[item['id']] = TreeNode.new(my_left, my_right, parent, depth, urls[:my_urlname], my_restricted)
          my_left = my_right + 1
        end

        [my_left, tree]
      end

      # Returns a Hash of TreeNode's indexed by their page ids
      #
      # Grabs the array representing a tree structure of pages passed as a parameter,
      # visits it and creates a map of TreeNodes indexed by page id featuring Nested Set
      # ordering information consisting of the left, right, depth and parent_id indexes as
      # well as a node's url and restricted status
      #
      # @param [Array]
      #   An Array representing a tree of Alchemy::Page's
      # @param [Alchemy::Page]
      #   The root page for the language being ordered
      #
      def create_tree(items, rootpage)
        _, tree = visit_nodes(items, rootpage.lft + 1, rootpage.id, rootpage.depth + 1, {}, "", rootpage.restricted)
        tree
      end

      # Returns a pair, the path that a given tree node should take, and the path its children should take
      #
      # This function will add a node's own slug into their ancestor's path
      # in order to create the full URL of a node
      #
      # NOTE: external and invisible pages are not part of the full path of their children
      #
      # @param [String]
      #   The node's ancestors path
      # @param [Hash]
      #   A children node
      #
      def process_url(ancestors_path, item)
        default_urlname = (ancestors_path.blank? ? "" : "#{ancestors_path}/") + item['slug'].to_s

        pair = {my_urlname: default_urlname, children_path: default_urlname}

        if item['external'] == true || item['visible'] == false
          # children ignore an ancestor in their path if external or invisible
          pair[:children_path] = ancestors_path
        end

        pair
      end

      def load_page
        @page = Page.find(params[:id])
      end

      def pages_from_raw_request
        request.raw_post.split('&').map do |i|
          parts = i.split('=')
          {
            parts[0].gsub(/[^0-9]/, '') => parts[1]
          }
        end
      end

      def redirect_path_for_switch_language
        if request.referer && request.referer.include?('admin/layoutpages')
          admin_layoutpages_path
        else
          admin_pages_path
        end
      end

      def redirect_path_after_create_page
        if @page.redirects_to_external? || !@page.editable_by?(current_alchemy_user)
          admin_pages_path
        else
          params[:redirect_to] || edit_admin_page_path(@page)
        end
      end

      def page_params
        params.require(:page).permit(*secure_attributes)
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
          parent = Page.find_by(id: params[:page][:parent_id]) || Page.root
          Page.copy_and_paste(source, parent, params[:page][:name])
        end
      end

      def set_root_page
        @page_root = Language.current_root_page
      end

      def serialized_page_tree
        PageTreeSerializer.new(@page, ability: current_ability,
                                      user: current_alchemy_user,
                                      full: params[:full] == 'true')
      end
    end
  end
end
