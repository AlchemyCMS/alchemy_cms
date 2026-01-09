# frozen_string_literal: true

module Alchemy
  module BaseHelper
    # Logs a message in the Rails logger (warn level)
    # and optionally displays an error message to the user.
    def warning(message, text = nil)
      Logger.warn(message)
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
    def render_message(type = :info, msg = nil, &)
      render Alchemy::Admin::Message.new(msg || capture(&), type: type)
    end
  end
end
