# frozen_string_literal: true

module Alchemy
  module Scrubbers
    class SafeList < Loofah::Scrubber
      attr_reader :safe_tags, :safe_attributes

      def initialize(config)
        @direction = :top_down
        @safe_tags = config[:safe_tags] || Rails::HTML::SafeListSanitizer::DEFAULT_ALLOWED_TAGS
        @safe_attributes = config[:safe_attributes] || Rails::HTML::SafeListSanitizer::DEFAULT_ALLOWED_ATTRIBUTES
      end

      def scrub(node)
        return CONTINUE if sanitize(node) == CONTINUE
        if Loofah::HTML5::Scrub.allowed_element?(node.name)
          node.before(node.children)
        end
        node.remove
        STOP
      end

      private

      def sanitize(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if allowed_element?(node.name)
            scrub_attributes(node)
            return Loofah::Scrubber::CONTINUE
          end
        when Nokogiri::XML::Node::TEXT_NODE
          return Loofah::Scrubber::CONTINUE
        end
        Loofah::Scrubber::STOP
      end

      def allowed_element?(node_name)
        node_name.in?(safe_tags)
      end

      def scrub_attributes(node)
        node.attribute_nodes.each do |attr_node|
          if safe_attributes.include?(attr_node.name)
            next
          else
            attr_node.remove
          end
        end
      end
    end
  end
end
