# frozen_string_literal: true

module Alchemy
  class TagValidations
    def self.call(klass)
      new(klass).call
    end

    def initialize(klass)
      @klass = klass
    end

    def call
      klass.validates :name, presence: true, uniqueness: {case_sensitive: true}
    end

    private

    attr_reader :klass
  end
end
