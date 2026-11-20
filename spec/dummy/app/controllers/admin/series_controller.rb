# frozen_string_literal: true
class Admin::SeriesController < Alchemy::Admin::ResourcesController
  private

  # Opted in, so the system specs render Alchemy's resource views under the admin CSP.
  def apply_content_security_policy? = true
end
