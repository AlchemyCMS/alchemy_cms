# frozen_string_literal: true

module Alchemy
  # Translates TinyMCE toolbar/plugin config into Tiptap config.
  #
  # Tiptap v3 StarterKit already includes:
  #   Nodes:  Blockquote, BulletList, CodeBlock, Document, HardBreak,
  #           Heading, HorizontalRule, ListItem, OrderedList, Paragraph, Text
  #   Marks:  Bold, Code, Italic, Link, Strike, Underline
  #   Exts:   Dropcursor, Gapcursor, Undo/Redo, ListKeymap, TrailingNode
  #
  # So we only need extra extensions for features OUTSIDE of StarterKit:
  #   Subscript, Superscript, TextAlign, TextStyle, Color, Highlight,
  #   Image, Table/TableRow/TableHeader/TableCell
  #
  class TinymceAdapter
    # TinyMCE button name => { button: tiptap_name, extra: [extensions not in StarterKit] }
    BUTTON_MAP = {
      # StarterKit marks
      "bold" => {button: "bold"},
      "italic" => {button: "italic"},
      "underline" => {button: "underline"},
      "strikethrough" => {button: "strike"},
      "code" => {button: "code"},

      # StarterKit nodes
      "formatselect" => {button: "heading"},
      "blockquote" => {button: "blockquote"},
      "hr" => {button: "horizontalRule"},
      "bullist" => {button: "bulletList"},
      "numlist" => {button: "orderedList"},

      # StarterKit functionality
      "undo" => {button: "undo"},
      "redo" => {button: "redo"},
      "removeformat" => {button: "clearFormat"},
      "indent" => {button: "indent"},
      "outdent" => {button: "outdent"},

      # StarterKit Link (v3)
      "alchemy_link" => {button: "alchemyLink"},
      "link" => {button: "alchemyLink"},
      "unlink" => {button: "unlink"},
      "anchor" => {button: "anchor"},

      # -- Extra extensions needed --
      "subscript" => {button: "subscript", extra: %w[Subscript]},
      "superscript" => {button: "superscript", extra: %w[Superscript]},
      "alignleft" => {button: "alignLeft", extra: %w[TextAlign]},
      "aligncenter" => {button: "alignCenter", extra: %w[TextAlign]},
      "alignright" => {button: "alignRight", extra: %w[TextAlign]},
      "alignjustify" => {button: "alignJustify", extra: %w[TextAlign]},
      "forecolor" => {button: "color", extra: %w[TextStyle Color]},
      "backcolor" => {button: "highlight", extra: %w[Highlight]},
      "image" => {button: "image", extra: %w[Image]},
      "table" => {button: "table", extra: %w[Table TableRow TableHeader TableCell]},
      "media" => {button: "video", extra: %w[Video]},

      # Handled natively by Tiptap — no button needed
      "pastetext" => {button: nil},
      "charmap" => {button: nil},
      "fullscreen" => {button: nil}
    }.freeze

    PLUGIN_MAP = {
      "table" => %w[Table TableRow TableHeader TableCell],
      "textcolor" => %w[TextStyle Color],
      "colorpicker" => %w[TextStyle Color]
    }.freeze

    def self.call(tinymce_settings)
      new(tinymce_settings).convert
    end

    def initialize(tinymce_settings)
      @settings = (tinymce_settings || {}).deep_symbolize_keys
    end

    def convert
      {
        extensions: resolve_extensions,
        toolbar: convert_toolbar,
        heading_levels: extract_heading_levels
      }.compact
    end

    private

    def convert_toolbar
      toolbar_strings = Array(@settings[:toolbar])
      return default_toolbar if toolbar_strings.empty?

      toolbar_strings.flat_map { |row|
        row.to_s.split("|").map { |group|
          group.split(/\s+/).filter_map { |btn|
            mapping = BUTTON_MAP[btn]
            mapping ? mapping[:button] : btn.presence
          }
        }
      }
    end

    def resolve_extensions
      extra = Set.new

      Array(@settings[:toolbar]).each do |row|
        row.to_s.split(/[\s|]+/).each do |btn|
          mapping = BUTTON_MAP[btn]
          extra.merge(mapping[:extra]) if mapping&.dig(:extra)
        end
      end

      Array(@settings[:plugins]).flatten.each do |p|
        p.to_s.split(/\s+/).each do |plugin|
          extra.merge(PLUGIN_MAP[plugin]) if PLUGIN_MAP[plugin]
        end
      end

      extra.empty? ? nil : extra.to_a.sort
    end

    def extract_heading_levels
      fmt = @settings[:block_formats]
      return nil unless fmt

      levels = fmt.to_s.scan(/h(\d)/).flatten.map(&:to_i)
      levels.empty? ? nil : levels
    end

    def default_toolbar
      [
        %w[bold italic underline strike],
        %w[heading bulletList orderedList],
        %w[alchemyLink unlink],
        %w[undo redo]
      ]
    end
  end
end
