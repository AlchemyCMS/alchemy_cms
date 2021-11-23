module Alchemy
  mattr_accessor :error_notification_handler

  @@error_notification_handler = Proc.new { |error|
    if defined?(Airbrake)
      notify_airbrake(error) unless Rails.env.development? || Rails.env.test?
    end
  }
end
