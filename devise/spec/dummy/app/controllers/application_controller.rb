class ApplicationController < ActionController::Base
  # @See https://github.com/AlchemyCMS/alchemy-devise/issues/80
  before_action { current_user }
end
