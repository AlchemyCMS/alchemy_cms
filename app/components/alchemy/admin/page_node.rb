module Alchemy
  module Admin
    class PageNode < ViewComponent::Base
      with_collection_parameter :page

      attr_reader :page

      delegate :current_alchemy_user,
        :render_icon,
        :link_to_dialog,
        :link_to_confirm_dialog,
        :page_layout_missing_warning,
        to: :helpers

      def initialize(page:)
        @page = page
      end

      def can?(action)
        helpers.can?(action, page.__getobj__)
      end

      # Memoized URL path
      def url(key)
        self.class.routes[key].sub(PAGE_ID, page.id.to_s)
      end

      # Memoized translation lookup
      def t(key)
        self.class.translations[key]
      end

      PAGE_ID = "__ID__"

      class << self
        # URL templates - computed once, reused for all pages
        def routes
          @_routes ||= begin
            router = Alchemy::Engine.routes.url_helpers
            {
              edit_page: router.edit_admin_page_path(PAGE_ID),
              info_page: router.info_admin_page_path(PAGE_ID),
              configure_page: router.configure_admin_page_path(PAGE_ID),
              page: router.admin_page_path(PAGE_ID),
              new_child_page: router.new_admin_page_path(parent_id: PAGE_ID),
              clipboard_insert: router.insert_admin_clipboard_path(
                remarkable_type: :pages,
                remarkable_id: PAGE_ID
              )
            }.freeze
          end
        end

        # Translations - computed once, reused for all pages
        def translations
          @_translations ||= {
            cannot_edit_page: Alchemy.t("Your user role does not allow you to edit this page"),
            edit_page: Alchemy.t(:edit_page),
            page_infos: Alchemy.t(:page_infos),
            edit_page_properties: Alchemy.t(:edit_page_properties),
            copy_page: Alchemy.t(:copy_page),
            delete_page: Alchemy.t(:delete_page),
            confirm_to_delete_page: Alchemy.t(:confirm_to_delete_page),
            create_page: Alchemy.t(:create_page)
          }.freeze
        end
      end
    end
  end
end
