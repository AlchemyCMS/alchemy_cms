# frozen_string_literal: true

require_relative "tasks/add_page_versions"

module Alchemy
  class Upgrader::SixPointZero < Upgrader
    class << self
      def create_public_page_versions
        desc "Create public page versions for pages"
        Alchemy::Upgrader::Tasks::AddPageVersions.new.create_public_page_versions
      end
    end
  end
end
