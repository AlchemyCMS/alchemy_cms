module Alchemy
  class UpdateChecker
    def initialize(origin: nil)
      @origin = origin
    end

    # Returns true if a newer Alchemy version is available.
    # @return [Boolean]
    def update_available?
      Alchemy.gem_version < latest_version
    end

    # Returns latest Alchemy gem version.
    # @return [Gem::Version]
    def latest_version
      @_latest_version ||= Gem::Version.new(
          update_check_service.new(origin:).latest_version
        )
    end

    private

    attr_reader :origin

    def update_check_service
      case Alchemy.config.update_check_service
      when :alchemy_app
        UpdateChecks::AlchemyApp
      when :ruby_gems
        UpdateChecks::RubyGems
      else
        Struct.new(:origin) do
          def latest_version
            Alchemy.gem_version
          end
        end
      end
    end
  end
end
