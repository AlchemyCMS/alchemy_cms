# frozen_string_literal: true

module Alchemy
  class BaseSerializer
    include ActiveModel::Serializers::JSON

    attr_reader :object, :opts

    def initialize(object, opts = {})
      @object = object
      @opts = opts
    end

    # The attributes to be serialized. See ActiveModel::Serialization.
    # By default, serialize all columns from the AR object.
    def attributes
      Hash[object.class.column_names.map { |c| [c, nil] }]
    end

    private

    # If the presenter implements an attribute, use that. Otherwise, delegate to
    # the object.
    def read_attribute_for_serialization(key)
      if respond_to?(key)
        send(key)
      else
        object.send(key)
      end
    end
  end
end
