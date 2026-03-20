# frozen_string_literal: true

class Admin::LocationsController < Alchemy::Admin::ResourcesController
  private

  def permitted_ransack_search_fields
    super + [
      "events_name_cont"
    ]
  end
end
