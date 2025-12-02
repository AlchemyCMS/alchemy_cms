# frozen_string_literal: true

require "loofah"

module Alchemy
  # A Loofah scrubber that sanitizes SVG content by removing
  # dangerous elements and attributes that could execute scripts
  # or load malicious external resources.
  class SvgScrubber < ::Loofah::Scrubber
    # Elements that can execute scripts or load external resources
    DANGEROUS_ELEMENTS = %w[
      script
      foreignObject
      iframe
      object
      embed
      handler
      listener
    ].freeze

    # Animation elements that are dangerous only when targeting URL attributes
    ANIMATION_ELEMENTS = %w[
      animate
      animateMotion
      animateTransform
      set
    ].freeze

    # Attributes that animations should not be allowed to target
    DANGEROUS_ANIMATION_TARGETS = %w[
      href
      xlink:href
    ].freeze

    # Attributes that can contain javascript: URLs
    URL_ATTRIBUTES = %w[
      href
      xlink:href
      formaction
      src
      data
      srcdoc
    ].freeze

    # Protocols that are safe in URL attributes
    SAFE_URL_PROTOCOLS = %w[
      http
      https
    ].freeze

    # Safe data URI MIME types (images only, no text/html or SVG)
    SAFE_DATA_URI_TYPES = %w[
      data:image/png
      data:image/jpeg
      data:image/jpg
      data:image/gif
      data:image/webp
      data:image/avif
    ].freeze

    def scrub(node)
      # Remove dangerous elements entirely
      if DANGEROUS_ELEMENTS.include?(node.name)
        node.remove
        return
      end

      # Remove animation elements only if they target dangerous attributes
      if ANIMATION_ELEMENTS.include?(node.name)
        target = node["attributeName"]&.downcase
        if DANGEROUS_ANIMATION_TARGETS.include?(target)
          node.remove
          return
        end
      end

      node.attributes.each do |attr_name, attr_obj|
        attr_lower = attr_name.downcase

        # Remove all event handlers (on*)
        if attr_lower.start_with?("on")
          node.remove_attribute(attr_name)
          next
        end

        # Check URL attributes for dangerous protocols
        if URL_ATTRIBUTES.include?(attr_lower)
          value = attr_obj.value.to_s.strip.downcase.gsub(/[\s\x00-\x1f]+/, "")
          unless safe_url?(value)
            node.remove_attribute(attr_name)
          end
          next
        end

        # Remove style attributes with dangerous content
        if attr_lower == "style"
          value = attr_obj.value.to_s.downcase
          if value.match?(/javascript:|expression\(|vbscript:|url\s*\(\s*["']?\s*(?:javascript|vbscript|data:text\/html):/i)
            node.remove_attribute(attr_name)
          end
        end
      end
    end

    private

    def safe_url?(value)
      return true if value.empty?
      return true if value.start_with?("#", "/") # Local references
      return true if SAFE_URL_PROTOCOLS.any? { |protocol| value.start_with?("#{protocol}:") }
      return true if SAFE_DATA_URI_TYPES.any? { |type| value.start_with?(type) }

      # Block javascript:, vbscript:, data:text/html, etc.
      !value.match?(/\A[a-z]+:/i)
    end
  end
end
