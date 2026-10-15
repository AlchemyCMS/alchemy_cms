# frozen_string_literal: true

module Alchemy
  module Configurations
    module Menu
      DEFAULT = [
        {
          name: "dashboard",
          title: "Home",
          position: 1,
          icon: "home-2",
          url: -> { alchemy.admin_dashboard_path },
          condition: -> { can?(:index, :alchemy_admin_dashboard) }
        },
        {
          name: "pages",
          title: "modules.pages",
          position: 2,
          icon: "pages",
          url: -> { alchemy.admin_pages_path },
          condition: -> { can?(:index, :alchemy_admin_pages) },
          children: [
            {
              title: "modules.pages",
              url: -> { alchemy.admin_pages_path },
              condition: -> { can?(:index, :alchemy_admin_pages) }
            },
            {
              title: "modules.layoutpages",
              url: -> { alchemy.admin_layoutpages_path },
              condition: -> { can?(:index, :alchemy_admin_layoutpages) }
            }
          ]
        },
        {
          name: "menus",
          title: "modules.menus",
          position: 3,
          icon: "menu-2",
          url: -> { alchemy.admin_nodes_path },
          condition: -> { can?(:index, :alchemy_admin_nodes) }
        },
        {
          name: "languages",
          title: "modules.languages",
          position: 4,
          icon: "translate-2",
          icon_style: "none",
          url: -> { alchemy.admin_languages_path },
          condition: -> { can?(:index, :alchemy_admin_languages) }
        },
        {
          name: "sites",
          title: "modules.sites",
          position: 5,
          icon: "global",
          url: -> { alchemy.admin_sites_path },
          condition: -> { can?(:index, :alchemy_admin_sites) }
        },
        {
          name: "tags",
          title: "modules.tags",
          position: 6,
          icon: "price-tag-3",
          url: -> { alchemy.admin_tags_path },
          condition: -> { can?(:index, :alchemy_admin_tags) }
        },
        {
          name: "archive",
          title: "modules.library",
          position: 7,
          icon: "archive-drawer",
          url: -> { alchemy.admin_pictures_path },
          condition: -> { can?(:index, :alchemy_admin_pictures) },
          children: [
            {
              title: "modules.pictures",
              url: -> { alchemy.admin_pictures_path },
              condition: -> { can?(:index, :alchemy_admin_pictures) }
            },
            {
              title: "modules.attachments",
              url: -> { alchemy.admin_attachments_path },
              condition: -> { can?(:index, :alchemy_admin_attachments) }
            }
          ]
        }
      ].freeze
    end
  end
end
