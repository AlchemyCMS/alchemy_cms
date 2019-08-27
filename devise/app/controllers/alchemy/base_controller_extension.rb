module Alchemy
  module BaseControllerExtension
    def self.prepended(base)
      base.before_action(:store_user_request_time)
    end

    private

    # Stores the users request time.
    def store_user_request_time
      if alchemy_user_signed_in?
        current_alchemy_user.store_request_time!
      end
    end
  end
end

Alchemy::BaseController.prepend Alchemy::BaseControllerExtension
