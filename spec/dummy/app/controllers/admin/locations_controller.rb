# frozen_string_literal: true

class Admin::LocationsController < Alchemy::Admin::ResourcesController
  private

  # Opted in, so the system specs render Alchemy's resource views under the admin CSP.
  def apply_content_security_policy? = true

  def permitted_ransack_search_fields
    super + [
      "events_name_cont"
    ]
  end
end
