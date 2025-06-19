# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureThumb, if: Alchemy.storage_adapter.dragonfly? do
  it { should belong_to(:picture).class_name("Alchemy::Picture") }
  it { should validate_presence_of(:signature) }
  it { should validate_presence_of(:uid) }
end
