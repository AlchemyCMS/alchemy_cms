# frozen_string_literal: true

# Stands in for an engine that opts into Alchemy's admin policy without
# inheriting from Alchemy::Admin::BaseController, the way alchemy-devise does.
class CspOptInController < ApplicationController
  include Alchemy::Admin::CspProtection

  def index
    render plain: "ok"
  end
end
