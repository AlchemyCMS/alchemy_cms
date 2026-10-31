# frozen_string_literal: true

module Alchemy
  class Upgrader
    # Removes the +position+ from +menu.add+ calls. Positions within the default
    # menu turn the call into a +menu.insert+ call at the index the position
    # sorted the entry to.
    #
    # Requires Prism, which only ships with Ruby >= 3.3.
    class MenuPositionRewriter
      # @param [String] source
      # @return [Array(String, Integer, Integer)]
      #   The new source, the number of rewritten and of untouched calls
      def rewrite(source)
        require "prism"

        result = Prism.parse(source)
        return [source, 0, 1] if result.errors.any?

        edits = []
        rewritten = 0
        manual = 0
        each_positioned_menu_add(result.value) do |call, elements, position|
          call_edits = edits_for(call, elements, position)
          if call_edits
            edits.concat(call_edits)
            rewritten += 1
          else
            manual += 1
          end
        end

        new_source = source.b
        edits.sort_by { |start_offset, end_offset, _| [start_offset, end_offset] }.reverse_each do |start_offset, end_offset, replacement|
          new_source[start_offset...end_offset] = replacement.b
        end

        [new_source.force_encoding(source.encoding), rewritten, manual]
      end

      private

      def each_positioned_menu_add(node, &block)
        if menu_add?(node)
          elements = node.arguments.arguments.first.elements
          position = elements.find do |element|
            element.is_a?(Prism::AssocNode) &&
              (element.key.is_a?(Prism::SymbolNode) || element.key.is_a?(Prism::StringNode)) &&
              element.key.unescaped == "position"
          end
          yield node, elements, position if position
        end

        node.compact_child_nodes.each { |child| each_positioned_menu_add(child, &block) }
      end

      def menu_add?(node)
        node.is_a?(Prism::CallNode) &&
          node.name == :add &&
          node.receiver.is_a?(Prism::CallNode) &&
          node.receiver.name == :menu &&
          node.arguments&.arguments&.size == 1 &&
          (node.arguments.arguments.first.is_a?(Prism::HashNode) || node.arguments.arguments.first.is_a?(Prism::KeywordHashNode))
      end

      def edits_for(call, elements, position)
        value = case position.value
        when Prism::IntegerNode then Integer(position.value.slice)
        when Prism::FloatNode then Float(position.value.slice)
        end
        return if value.nil? || elements.size == 1

        i = elements.index(position)
        edits = if i < elements.size - 1
          [[position.location.start_offset, elements[i + 1].location.start_offset, ""]]
        else
          [[elements[i - 1].location.end_offset, position.location.end_offset, ""]]
        end

        index = Alchemy::Configurations::MenuItem.index_for_legacy_position(value)
        if index < Alchemy::Configurations::Menu::DEFAULT.size
          argument = call.arguments.arguments.first
          separator = if call.opening_loc && argument.location.start_line > call.opening_loc.start_line
            ",\n#{" " * argument.location.start_column}"
          else
            ", "
          end
          edits << [call.message_loc.start_offset, call.message_loc.end_offset, "insert"]
          edits << [argument.location.start_offset, argument.location.start_offset, "#{index}#{separator}"]
        end

        edits
      end
    end
  end
end
