unless ENV['CI']

  require 'localeapp/rails'

  Localeapp.configure do |config|
    config.api_key = 'afwgJCX6Xq40Y2gQSU9sdYFJ2XmQdAhgKmZPd69TOLdsT7e4Sy'
  end

end
