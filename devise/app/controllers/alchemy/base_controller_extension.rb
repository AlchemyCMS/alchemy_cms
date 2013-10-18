Alchemy::BaseController.class_eval do
  before_action :store_user_request_time

  private

  # Stores the users request time.
  def store_user_request_time
    if alchemy_user_signed_in?
      current_alchemy_user.store_request_time!
    end
  end
end
