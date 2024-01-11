# frozen_string_literal: true

module Alchemy
  module BaseHelper
    # An alias for truncate.
    # Left here for downwards compatibilty.
    def shorten(text, length)
      text.truncate(length: length)
    end

    # Logs a message in the Rails logger (warn level)
    # and optionally displays an error message to the user.
    def warning(message, text = nil)
      Logger.warn(message, caller(1..1))
      unless text.nil?
        render_message(:warning) do
          text.html_safe
        end
      end
    end

    # Render a Remix icon
    #
    # @param icon_name [String] icon name
    # @option options - style: nil [String] icon style. line or fill
    # @option options - size: nil [String] icon size
    #
    # @return [String]
    def render_icon(icon_name, options = {})
      options = {style: "line", fixed_width: true}.merge(options)
      style = options[:style] && "-#{ri_style(options[:style])}"
      classes = [
        "icon",
        "ri-#{ri_icon(icon_name)}#{style}",
        options[:size] ? "ri-#{options[:size]}" : nil,
        options[:fixed_width] ? "ri-fw" : nil,
        options[:class]
      ].compact
      content_tag("i", nil, class: classes)
    end

    # Returns a div with an icon and the passed content
    # The default message type is info, but you can also pass
    # other types like :warning or :error
    #
    # === Usage:
    #
    #   <%= render_message :warning do
    #     <p>Caution! This is a warning!</p>
    #   <% end %>
    #
    def render_message(type = :info, msg = nil, &blk)
      icon_class = message_icon_class(type)
      if blk
        content_tag :div, render_icon(icon_class) + capture(&blk), class: "#{type} message"
      else
        content_tag :div, render_icon(icon_class) + msg, class: "#{type} message"
      end
    end

    # Renders the flash partial (+alchemy/admin/partials/flash+)
    #
    # @param [String] notice The notice you want to display
    # @param [Symbol] style The style of this flash. Valid values are +:notice+ (default), +:warn+ and +:error+
    #
    def render_flash_notice(notice, style = :notice)
      render("alchemy/admin/partials/flash", flash_type: style, message: notice)
    end

    # Checks if the given argument is a String or a Page object.
    # If a String is given, it tries to find the page via page_layout
    # Logs a warning if no page is given.
    def page_or_find(page)
      unless Language.current
        warning("No default language set up")
        return nil
      end

      if page.is_a?(String)
        page = Language.current.pages.find_by(page_layout: page)
      end
      if page.blank?
        warning("No Page found for #{page.inspect}")
        nil
      else
        page
      end
    end

    # Returns the icon name for given message type
    #
    # @param message_type [String] The message type. One of +warning+, +info+, +notice+, +error+
    # @return [String] The icon name
    def message_icon_class(message_type)
      case message_type.to_s
      when "warning", "warn", "alert" then "exclamation"
      when "notice" then "check"
      when "error" then "bug"
      when "hint" then "info"
      else
        message_type
      end
    end

    private

    # Returns the Remix icon name for given icon name
    #
    # @param icon_name [String] The icon name.
    # @return [String] The Remix icon class
    def ri_icon(icon_name)
      case icon_name.to_s
      when "minus", "remove", "delete"
        "delete-bin-2"
      when "plus"
        "add"
      when "copy"
        "file-copy"
      when "download"
        "download-2"
      when "upload"
        "upload-2"
      when "exclamation"
        "alert"
      when "info-circle", "info"
        "information"
      when "times"
        "close"
      when "tag"
        "price-tag-3"
      when "cog"
        "settings-3"
      else
        icon_name
      end
    end

    # Returns the Remix icon style for given style
    #
    # @param style [String] The style name
    # @return [String] The RemixIcon style
    def ri_style(style)
      case style.to_s
      when "solid", "fill"
        "fill"
      when "line", "regular"
        "line"
      else
        style
      end
    end
  end
end
