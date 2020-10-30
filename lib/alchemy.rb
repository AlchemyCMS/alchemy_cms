# frozen_string_literal: true

module Alchemy
  YAML_WHITELIST_CLASSES = %w(Symbol Date Regexp)

  # Define page publish targets
  #
  # A publish target is a ActiveJob that gets performed
  # whenever a user clicks the publish page button.
  #
  # Use this to trigger deployment hooks of external
  # services in an asychronous way.
  #
  # == Example
  #
  #     # app/jobs/publish_job.rb
  #     class PublishJob < ApplicationJob
  #       def perform(page)
  #         RestClient.post(ENV['BUILD_HOOK_URL'])
  #       end
  #     end
  #
  #     # config/initializers/alchemy.rb
  #     Alchemy.publish_targets << PublishJob
  #
  def self.publish_targets
    @_publish_targets ||= Set.new
  end
end
