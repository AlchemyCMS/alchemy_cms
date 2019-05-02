# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each do |file|
  require file
end
