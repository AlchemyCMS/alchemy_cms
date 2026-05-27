# frozen_string_literal: true

module Alchemy
  module Configurations
    class Dashboard < Alchemy::Configuration
      option :stats, :collection, item_type: :class, default: [
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "PageCounts",
            style: "stat"
          }
        ],
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "UserCounts",
            style: "stat"
          }
        ],
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "PictureCounts",
            style: "stat"
          }
        ],
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "AttachmentCounts",
            style: "stat"
          }
        ]
      ]

      option :widgets, :collection, item_type: :class, default: [
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "LockedPages",
            style: "wide"
          }
        ],
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "RecentPages",
            style: "wide"
          }
        ],
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "ElementUsage",
            style: "usage",
            loading: "lazy"
          }
        ],
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "PageUsage",
            style: "usage",
            loading: "lazy"
          }
        ],
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "Sites",
            loading: "lazy",
            condition: -> { helpers.multi_site? }
          }
        ],
        [
          "Alchemy::Admin::Dashboard::Widget", {
            id: "OnlineUsers",
            loading: "lazy",
            condition: -> {
              Alchemy.config.user_class.respond_to?(:logged_in)
            }
          }
        ]
      ]
    end
  end
end
