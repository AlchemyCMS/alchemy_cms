require "sprockets/manifest"

module NonStupidDigestAssets
  mattr_accessor :whitelist
  @@whitelist = []

  class << self
    def assets(assets)
      return assets if whitelist.empty?
      whitelisted_assets(assets)
    end

    private

    def whitelisted_assets(assets)
      assets.select do |logical_path, digest_path|
        whitelist.any? do |item|
          item === logical_path
        end
      end
    end
  end

  module CompileWithNonDigest
    def compile *args
      paths = super
      NonStupidDigestAssets.assets(assets).each do |(logical_path, digest_path)|
        full_digest_path = File.join dir, digest_path
        full_digest_gz_path = "#{full_digest_path}.gz"
        full_non_digest_path = File.join dir, logical_path
        full_non_digest_gz_path = "#{full_non_digest_path}.gz"

        if File.exists? full_digest_path
          logger.debug "Writing #{full_non_digest_path}"
          FileUtils.copy_file full_digest_path, full_non_digest_path, :preserve_attributes
        else
          logger.debug "Could not find: #{full_digest_path}"
        end
        if File.exists? full_digest_gz_path
          logger.debug "Writing #{full_non_digest_gz_path}"
          FileUtils.copy_file full_digest_gz_path, full_non_digest_gz_path, :preserve_attributes
        else
          logger.debug "Could not find: #{full_digest_gz_path}"
        end
      end
      paths
    end
  end
end

Sprockets::Manifest.send(:prepend, NonStupidDigestAssets::CompileWithNonDigest)
