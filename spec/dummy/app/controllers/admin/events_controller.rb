# frozen_string_literal: true

class Admin::EventsController < Alchemy::Admin::ResourcesController
  add_alchemy_filter :by_timeframe, type: :select, options: ["starting_today", "future"]
  add_alchemy_filter :by_location_id,
    type: :select,
    options: ->(query) { Location.joins(:events).merge(query.result.reorder(nil)).distinct.map { |l| [l.name, l.id] } }
end
