# frozen_string_literal: true

# Adds the model stamper ability to the provided user class
#
# It only adds it, if the user model is a active_record model.
#
if Alchemy.user_class < ActiveRecord::Base
  Alchemy.user_class.class_eval do
    model_stamper
    stampable stamper_class_name: Alchemy.user_class_name
  end
end
