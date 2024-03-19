# frozen_string_literal: true

module Alchemy
  module BaseHelper
    # An alias for truncate.
    # Left here for downwards compatibilty.
    # @deprecated
    def shorten(text, length)
      text.truncate(length: length)
    end
    deprecate :shorten, deprecator: Alchemy::Deprecation

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
    # @option options - style: fill [String] icon style. line or fill. Pass false for no style.
    # @option options - size: nil [String] icon size
    #
    # @return [String]
    def render_icon(icon_name, options = {})
      render Alchemy::Admin::Icon.new(icon_name, options)
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
      render Alchemy::Admin::Message.new(msg || capture(&blk), type: type)
    end

    # Renders a dismissable growl message.
    #
    # @param [String] notice - The notice you want to display
    # @param [Symbol] type - The type of this flash. Valid values are +:notice+ (default), +:warn+, +:info+ and +:error+
    #
    def render_flash_notice(notice, type = :notice)
      render Alchemy::Admin::Message.new(notice, type: type, dismissable: true)
    end

    # Checks if the given argument is a String or a Page object.
    # If a String is given, it tries to find the page via page_layout
    # Logs a warning if no page is given.
    # @deprecated
    def page_or_find(page)
      unless Current.language
        warning("No default language set up")
        return nil
      end

      if page.is_a?(String)
        page = Current.language.pages.find_by(page_layout: page)
      end
      if page.blank?
        warning("No Page found for #{page.inspect}")
        nil
      else
        page
      end
    end
    deprecate :page_or_find, deprecator: Alchemy::Deprecation
  end
end
