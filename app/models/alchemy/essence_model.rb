module Alchemy
  class Alchemy::EssenceModel < BaseRecord
    include Alchemy::Admin::ModelsHelper

    acts_as_essence ingredient_column: :model

    def model
      if model_class and model_id
        Object.const_get(model_class).find_by(id: model_id)
      end
    end
  end
end
