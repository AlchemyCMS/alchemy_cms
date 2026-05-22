module Alchemy
  module RichtextEditor
    module Tiptap
      ICONS = {
        bold: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M8 11h4.5a2.5 2.5 0 0 0 0-5H8v5Zm10 4.5c0 2.5-2 4.5-4.5 4.5H6V4h6.5a4.5 4.5 0 0 1 3.3 7.6c1.3.8 2.2 2.2 2.2 3.9ZM8 13v5h5.5a2.5 2.5 0 0 0 0-5H8Z"/></svg>',
        italic: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M15 20H7v-2h3l2-12H9V4h8v2h-3l-2 12h3v2Z"/></svg>',
        underline: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M8 3v9a4 4 0 0 0 8 0V3h2v9a6 6 0 0 1-12 0V3h2ZM4 20h16v2H4v-2Z"/></svg>',
        strike: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M17.2 14c.2.5.3 1 .3 1.7 0 1.4-.5 2.4-1.6 3.2-1 .7-2.5 1.1-4.3 1.1-1.7 0-3.3-.4-4.9-1.1v-2.3c1.5.9 3 1.3 4.7 1.3 2.5 0 3.8-.7 3.8-2.2a2.2 2.2 0 0 0-.7-1.7H3v-2h18v2h-3.8ZM13 11H7.6a3.2 3.2 0 0 1-1.1-2.5c0-1.3.5-2.3 1.4-3.2 1-.9 2.4-1.3 4.3-1.3 1.5 0 2.9.3 4.2 1V7c-1.2-.7-2.5-1-3.9-1-2.5 0-3.7.8-3.7 2.4 0 .4.2.7.6 1 .5.4 1 .6 1.6.8l2 .7Z"/></svg>',
        subscript: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="m5.6 4 4.9 6 4.9-6H18l-6.2 7.5L18 19h-2.6l-4.9-6-5 6H3l6.2-7.5L3 4h2.6Zm16.2 12a.8.8 0 1 0-1.6.2l-1.1.3a2 2 0 1 1 3.3 1L20.7 19H23v1h-4v-1l2.6-2.4.2-.6Z"/></svg>',
        superscript: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="m5.6 5 4.9 6 4.9-6H18l-6.2 7.5L18 20h-2.6l-4.9-6-5 6H3l6.2-7.5L3 5h2.6Zm16 1.6a.8.8 0 0 0-.6-1.4.8.8 0 0 0-.8 1l-1.1.3a2 2 0 1 1 3.3 1L20.7 9H23v1h-4V9l2.6-2.4Z"/></svg>',
        code: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M17 8.5 18.3 7l5 4.9-5 5-1.4-1.5 3.5-3.5-3.6-3.5Zm-10 0L3.6 12l3.6 3.5L5.6 17 .6 12l5-5 1.5 1.5Z"/></svg>',
        bulletList: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M8 4h13v2H8V4ZM4.5 6.5a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3Zm0 7a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3Zm0 6.9a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3ZM8 11h13v2H8v-2Zm0 7h13v2H8v-2Z"/></svg>',
        orderedList: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M5.8 3.5h-1l-1.5.4v1.5l1-.2v3.3H3V10h4V8.5H5.8v-5ZM10 4h11v2H10V4Zm0 7h11v2H10v-2Zm0 7h11v2H10v-2Zm-7.1-2.4A2.1 2.1 0 1 1 6.7 17l-1.4 1.6H7V20H3v-1.1L5.5 16l.1-.4a.6.6 0 0 0-1.2 0v.3H2.9v-.3Z"/></svg>',
        horizontalRule: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M2 11h2v2H2v-2Zm4 0h12v2H6v-2Zm14 0h2v2h-2v-2Z"/></svg>',
        clearFormat: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="m12.7 14-1.1 6h-2l1.3-7.7L3.5 5 5 3.5l15.6 15.6-1.4 1.4-6.4-6.4Zm-1-6.5L12 6h-1.8l-2-2H20v2h-6l-.5 3.3-1.7-1.8Z"/></svg>',
        undo: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="m5.8 7 2.6 2.5L6.9 11 2 6l5-5 1.4 1.5L5.8 5H13a8 8 0 1 1 0 16H4v-2h9a6 6 0 0 0 0-12H5.8Z"/></svg>',
        redo: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M18.2 7H11a6 6 0 0 0 0 12h9v2h-9a8 8 0 0 1 0-16h7.2l-2.6-2.5L17.1 1 22 6l-5 5-1.4-1.5L18.2 7Z"/></svg>',
        indent: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M3 4h18v2H3V4Zm0 15h18v2H3v-2Zm8-5h10v2H11v-2Zm0-5h10v2H11V9Zm-4 3.5L3 16V9l4 3.5Z"/></svg>',
        outdent: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M3 4h18v2H3V4Zm0 15h18v2H3v-2Zm8-5h10v2H11v-2Zm0-5h10v2H11V9Zm-8 3.5L7 9v7l-4-3.5Z"/></svg>',
        alignLeft: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M3 4h18v2H3V4Zm0 15h14v2H3v-2Zm0-5h18v2H3v-2Zm0-5h14v2H3V9Z"/></svg>',
        alignCenter: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M3 4h18v2H3V4Zm2 15h14v2H5v-2Zm-2-5h18v2H3v-2Zm2-5h14v2H5V9Z"/></svg>',
        alignRight: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M3 4h18v2H3V4Zm4 15h14v2H7v-2Zm-4-5h18v2H3v-2Zm4-5h14v2H7V9Z"/></svg>',
        alignJustify: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="M3 4h18v2H3V4Zm0 15h18v2H3v-2Zm0-5h18v2H3v-2Zm0-5h18v2H3V9Z"/></svg>',
        unlink: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="m17.7 14.8-1.5-1.4 1.5-1.4A4 4 0 1 0 12 6.3l-1.4 1.5-1.4-1.5L10.6 5a6 6 0 0 1 8.5 8.5l-1.4 1.4Zm-2.9 2.9L13.4 19A6 6 0 0 1 5 10.6l1.4-1.4 1.5 1.4L6.3 12a4 4 0 0 0 5.7 5.7l1.4-1.5 1.4 1.5Zm0-10 1.4 1.5-7 7-1.4-1.4 7-7Zm-9-5.4 2-.5 1 3.8-2 .6-1-4Zm9.5 16 1.9-.5 1 4-2 .4-1-3.8ZM2.3 5.9l3.9 1-.6 2-3.8-1 .5-2Zm16 9.5 4 1-.6 2-3.9-1.1.6-2Z"/></svg>',
        alchemyLink: '<svg viewBox="0 0 24 24" width="16" height="16"><path d="m17.7 14.8-1.5-1.4 1.5-1.4A4 4 0 1 0 12 6.3l-1.4 1.5-1.4-1.5L10.6 5a6 6 0 0 1 8.5 8.5l-1.4 1.4Zm-2.9 2.9L13.4 19A6 6 0 0 1 5 10.6l1.4-1.4 1.5 1.4L6.3 12a4 4 0 0 0 5.7 5.7l1.4-1.5 1.4 1.5Zm0-10 1.4 1.5-7 7-1.4-1.4 7-7Z"/></svg>'
      }

      private

      def tiptap_editor
        content_tag("alchemy-tiptap", tiptap_config) do
          safe_join([
            tiptap_toolbar,
            tag.div(class: "tiptap-content"),
            editor_text_area
          ])
        end
      end

      def tiptap_toolbar
        tag.div(class: "tiptap-toolbar") do
          safe_join(
            tiptap_config[:toolbar].map { tiptap_toolbar_group(_1) },
            tag.span(class: "tiptap-toolbar-separator")
          )
        end
      end

      def tiptap_toolbar_group(group)
        tag.span(class: "tiptap-toolbar-group") do
          safe_join(group.map { tiptap_toolbar_button(_1) })
        end
      end

      def tiptap_toolbar_button(button)
        icon = ICONS[button.to_sym] || button.first.upcase
        tag.button(
          icon.html_safe,
          data: {
            tiptap_button: button
          },
          class: "tiptap-toolbar-button",
          type: "button"
        )
      end

      def tiptap_config
        config = settings[:tiptap] || {toolbar: default_toolbar}
        config["readonly"] = true.to_json if !editable?
        config
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
end
