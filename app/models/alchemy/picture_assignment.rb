# frozen_string_literal: true

module Alchemy
  class PictureAssignment < ApplicationRecord
    belongs_to :picture
    belongs_to :assignee, polymorphic: true, dependent: :destroy
  end
end
