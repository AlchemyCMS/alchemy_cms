require "propshaft/asset"

module Alchemy
  module Propshaft
    module TinymceAsset
      # Allow TinyMCE assets to be accessed (in development mode) without a digest
      def fresh?(digest)
        super ||
          (digest.blank? && logical_path.to_s.starts_with?("tinymce/"))
      end
    end
  end
end

Propshaft::Asset.prepend Alchemy::Propshaft::TinymceAsset
