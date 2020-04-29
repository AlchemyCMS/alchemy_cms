# frozen_string_literal: true
require "dragonfly_svg"

# Logger
Dragonfly.logger = Rails.logger

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
