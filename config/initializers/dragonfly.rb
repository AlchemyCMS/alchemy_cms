# frozen_string_literal: true
require "dragonfly_svg"

# Logger
Dragonfly.logger = Rails.logger

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end

# Dragonfly 1.4.0 only allows `quality` as argument to `encode`
Dragonfly::ImageMagick::Processors::Encode::WHITELISTED_ARGS << "flatten"
