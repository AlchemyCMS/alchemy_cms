# frozen_string_literal: true
require "dragonfly_svg"
require "alchemy/dragonfly/processors/crop_resize"
require "alchemy/dragonfly/processors/auto_orient"

# Logger
Dragonfly.logger = Rails.logger

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end

# Dragonfly 1.4.0 only allows `quality` as argument to `encode`
Dragonfly::ImageMagick::Processors::Encode::WHITELISTED_ARGS << "flatten"

Rails.application.config.after_initialize do
  Dragonfly.app(:alchemy_pictures).add_processor(:crop_resize, Alchemy::Dragonfly::Processors::CropResize.new)
  Dragonfly.app(:alchemy_pictures).add_processor(:auto_orient, Alchemy::Dragonfly::Processors::AutoOrient.new)
end
