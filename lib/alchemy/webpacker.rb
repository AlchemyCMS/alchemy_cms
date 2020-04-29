# frozen_string_literal: true

require "webpacker"
require "webpacker/instance"

module Alchemy
  def self.webpacker
    @webpacker ||= ::Webpacker::Instance.new(
      root_path: ROOT_PATH,
      config_path: ROOT_PATH.join("config/webpacker.yml"),
    )
  end
end
