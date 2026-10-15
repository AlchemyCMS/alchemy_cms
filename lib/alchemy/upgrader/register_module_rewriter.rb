# frozen_string_literal: true

module Alchemy
  class Upgrader
    # Rewrites +Alchemy::Modules.register_module+ calls with a static literal
    # argument into +Alchemy.config.menu.add+ calls.
    #
    # Calls inside a +to_prepare+ block are guarded by the entry's name, because
    # +Alchemy.config.menu.add+ does not skip entries that are already present.
    #
    # Requires Prism, which only ships with Ruby >= 3.3.
    class RegisterModuleRewriter
      class NonLiteralError < StandardError; end

      RECEIVERS = ["Alchemy::Modules", "::Alchemy::Modules"].freeze

      KEYS = %w[
        name title engine_name position icon icon_style image inline_image turbo
        controller action nested_controllers nested_actions children nested
      ].freeze

      # @param [String] source
      # @return [Array(String, Integer, Integer)]
      #   The new source, the number of rewritten and of untouched calls
      def rewrite(source)
        require "prism"

        result = Prism.parse(source)
        return [source, 0, 1] if result.errors.any?

        replacements = []
        manual = 0
        each_register_module_call(result.value) do |call, in_to_prepare|
          replacement = replacement_for(call, source, in_to_prepare:)
          if replacement
            replacements << [call.location.start_offset, call.location.end_offset, replacement]
          else
            manual += 1
          end
        end

        new_source = source.b
        replacements.sort_by(&:first).reverse_each do |start_offset, end_offset, replacement|
          new_source[start_offset...end_offset] = replacement.b
        end

        [new_source.force_encoding(source.encoding), replacements.size, manual]
      end

      private

      def each_register_module_call(node, in_to_prepare = false, &block)
        if node.is_a?(Prism::CallNode) && node.name.to_s == "register_module"
          yield node, in_to_prepare
        end

        node.compact_child_nodes.each do |child|
          child_in_to_prepare = in_to_prepare ||
            (node.is_a?(Prism::CallNode) && node.name.to_s == "to_prepare" && child.equal?(node.block))
          each_register_module_call(child, child_in_to_prepare, &block)
        end
      end

      def replacement_for(call, source, in_to_prepare:)
        return unless RECEIVERS.include?(call.receiver&.slice)
        return if call.block

        arguments = call.arguments&.arguments || []
        return unless arguments.size == 1
        return unless arguments.first.is_a?(Prism::HashNode) || arguments.first.is_a?(Prism::KeywordHashNode)
        return unless heredocs_inside?(arguments.first, call, source)

        item = Alchemy::Configurations::MenuItem.from_legacy_hash(literal(arguments.first))
        return if in_to_prepare && item.name.blank?

        indent = " " * call.location.start_column
        if in_to_prepare
          <<~RUBY.chomp
            unless Alchemy.config.menu.any? { |item| item.name == #{item.name.inspect} }
            #{indent}  #{menu_add(item, "#{indent}  ")}
            #{indent}end
          RUBY
        else
          menu_add(item, indent)
        end
      rescue NonLiteralError, Alchemy::Configuration::ConfigurationError
        nil
      end

      def menu_add(item, indent)
        pairs = attributes(item).map do |key, value|
          if key == "children" || key == "nested"
            entries = value.map { |entry| "#{indent}    #{inline_hash(entry)}" }
            "#{indent}  #{key}: [\n#{entries.join(",\n")}\n#{indent}  ]"
          else
            "#{indent}  #{key}: #{value.inspect}"
          end
        end
        "Alchemy.config.menu.add(\n#{pairs.join(",\n")}\n#{indent})"
      end

      def inline_hash(item)
        pairs = attributes(item).map do |key, value|
          if key == "children" || key == "nested"
            "#{key}: [#{value.map { |entry| inline_hash(entry) }.join(", ")}]"
          else
            "#{key}: #{value.inspect}"
          end
        end
        "{#{pairs.join(", ")}}"
      end

      def attributes(item)
        KEYS.filter_map do |key|
          value = item.public_send(key)
          value = value.to_a if value.respond_to?(:to_a) && !value.is_a?(String)
          next if key == "turbo" && value != false
          next if value.nil? || value == []

          [key, value]
        end
      end

      def literal(node)
        case node
        when Prism::StringNode, Prism::SymbolNode
          node.unescaped
        # Squiggly heredocs and adjacent string literals are made of static parts
        when Prism::InterpolatedStringNode
          node.compact_child_nodes.map do |part|
            raise NonLiteralError unless part.is_a?(Prism::StringNode)

            part.unescaped
          end.join
        when Prism::IntegerNode
          Integer(node.slice)
        when Prism::FloatNode
          Float(node.slice)
        when Prism::TrueNode
          true
        when Prism::FalseNode
          false
        when Prism::NilNode
          nil
        when Prism::ArrayNode
          node.elements.map { |element| literal(element) }
        when Prism::HashNode, Prism::KeywordHashNode
          node.elements.to_h do |element|
            raise NonLiteralError unless element.is_a?(Prism::AssocNode)
            raise NonLiteralError unless element.key.is_a?(Prism::SymbolNode) || element.key.is_a?(Prism::StringNode)

            [element.key.unescaped, literal(element.value)]
          end
        else
          raise NonLiteralError
        end
      end

      # A heredoc body starts on the line after its opening, so it is only part
      # of the call if the call ends on a later line.
      def heredocs_inside?(node, call, source)
        heredocs = []
        collect_heredocs(node, heredocs)
        heredocs.all? do |heredoc|
          source.byteslice(heredoc.location.end_offset...call.location.end_offset).include?("\n")
        end
      end

      def collect_heredocs(node, heredocs)
        if (node.is_a?(Prism::StringNode) || node.is_a?(Prism::InterpolatedStringNode)) && node.slice.start_with?("<<")
          heredocs << node
        end
        node.compact_child_nodes.each { |child| collect_heredocs(child, heredocs) }
      end
    end
  end
end
