# frozen_string_literal: true

require "alchemy/shell"

module Alchemy
  class Upgrader
    extend Alchemy::Shell

    Dir["#{File.dirname(__FILE__)}/upgrader/*.rb"].sort.each { |f| require f }
  end
end
