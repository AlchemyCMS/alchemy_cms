# frozen_string_literal: true

require "alchemy/admin/preview_url"

module Alchemy
  YAML_WHITELIST_CLASSES = %w(Symbol Date Regexp)

  # Define page preview sources
  #
  # A preview source is a Ruby class returning an URL
  # that is used as source for the preview frame in the
  # admin UI.
  #
  # == Example
  #
  #     # lib/acme/preview_source.rb
  #     class Acme::PreviewSource < Alchemy::Admin::PreviewUrl
  #       def url_for(page)
  #         if page.site.name == "Next"
  #           "https://user:#{ENV['PREVIEW_HTTP_PASS']}@next.acme.com"
  #         else
  #           "https://www.acme.com"
  #         end
  #       end
  #     end
  #
  #     # config/initializers/alchemy.rb
  #     require "acme/preview_source"
  #     Alchemy.preview_sources << Acme::PreviewSource
  #
  #     # config/locales/de.yml
  #     de:
  #       activemodel:
  #         models:
  #           acme/preview_source: Acme Vorschau
  #
  def self.preview_sources
    @_preview_sources ||= begin
      Set.new << Alchemy::Admin::PreviewUrl
    end
  end

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
