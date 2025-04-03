# frozen_string_literal: true

class Admin::EventsController < Alchemy::Admin::ResourcesController
  add_alchemy_filter :by_timeframe, type: :select, options: ["starting_today", "future"]
  add_alchemy_filter :by_location_id,
    type: :select,
    options: ->(query) { Location.joins(:events).merge(query.result.reorder(nil)).distinct.map { |l| [l.name, l.id] } }
  add_alchemy_filter :starts_at_lteq, type: :datepicker

  before_action :set_default_filter, only: :index

  private

  def set_default_filter
    search_filter_params[:q] ||= {by_timeframe: "future"}
  end
end
