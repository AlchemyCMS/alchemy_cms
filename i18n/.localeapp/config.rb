require 'dotenv/load'

Localeapp.configure do |config|
  config.api_key                    = ENV['LOCALEAPP_API_KEY']
  config.translation_data_directory = 'config/locales'
  config.synchronization_data_file  = '.localeapp/log.yml'
  config.daemon_pid_file            = '.localeapp/localeapp.pid'
end
