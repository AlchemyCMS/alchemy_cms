module Alchemy
  class Site < ActiveRecord::Base
    cattr_accessor :current

    attr_accessible :host, :name

    # validations
    validates_presence_of :host
    validates_uniqueness_of :host

    # associations
    has_many :languages

    # Returns true if this site is the current site
    def current?
      self.class.current == self
    end
  end
end
