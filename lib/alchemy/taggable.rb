module Alchemy
  # ActsAsTaggableOn interface
  # Include this module to add tagging support to your model.
  module Taggable
    def self.included(base)
      base.acts_as_taggable
    end
  end
end
