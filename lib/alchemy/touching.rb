module Alchemy
  module Touching

    # Touches the timestamps and userstamps
    #
    def touch
      update_columns(updated_at: Time.now, updater_id: Alchemy.user_class.try(:stamper))
    end

  end
end
