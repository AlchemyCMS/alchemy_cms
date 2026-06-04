require "alchemy/version"

module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class SystemInfo < ViewComponent::Base
          delegate :alchemy, :render_message, to: :helpers

          def initialize
            @alchemy_version = Alchemy.version
          end

          private

          def logo
            @_logo_file ||= File.read(logo_file_path).html_safe
          end

          def git_source
            git_info = Alchemy.git_revision_info
            return unless git_info

            branch = git_info[:branch]
            revision = git_info[:revision]

            "(#{[branch, revision[0, 7]].compact.join(" @ ")})"
          end

          def logo_file_path
            Alchemy::Engine.root.join("app/assets/images/alchemy/admin/logo.svg")
          end
        end
      end
    end
  end
end
