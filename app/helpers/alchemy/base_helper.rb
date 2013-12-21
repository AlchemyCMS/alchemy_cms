module Alchemy
  module BaseHelper

    def _t(key, *args)
      I18n.t(key, *args)
    end

    # An alias for truncate.
    # Left here for downwards compatibilty.
    def shorten(text, length)
      text.truncate(:length => length)
    end

    def parse_sitemap_name(page)
      if multi_language?
        pathname = "/#{Language.current.code}/#{page.urlname}"
      else
        pathname = "/#{page.urlname}"
      end
      pathname
    end

    # Logs a message in the Rails logger (warn level) and optionally displays an error message to the user.
    def warning(message, text = nil)
      Logger.warn(message, caller.first)
      unless text.nil?
        warning = content_tag('p', :class => 'content_editor_error') do
          render_icon('warning') + text
        end
        return warning
      end
    end

    # Returns an icon
    def render_icon(icon_class)
      content_tag('span', '', :class => "icon #{icon_class}")
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
      if block_given?
        content_tag :div, render_icon(type) + capture(&blk), :class => "#{type} message"
      else
        content_tag :div, render_icon(type) + msg, :class => "#{type} message"
      end
    end

    # Returns an array of all pages in the same branch from current.
    # I.e. used to find the active page in navigation.
    def breadcrumb(current)
      return [] if current.nil?
      current.self_and_ancestors.where("parent_id IS NOT NULL")
    end

    # Returns the Alchemy configuration.
    #
    # *DO NOT REMOVE THIS HERE.*
    #
    # We need this, if an external engine or app includes this module into actionview.
    #
    def configuration(name)
      Alchemy::Config.get(name)
    end

    # Returns true if Alchemy is in multi language mode
    #
    # *DO NOT REMOVE THIS HERE.*
    #
    # We need this, if an external engine or app includes this module into actionview.
    #
    def multi_language?
      Alchemy::Language.published.count > 1
    end

    # Renders the flash partial (+alchemy/admin/partials/flash+)
    #
    # @param [String] notice The notice you want to display
    # @param [Symbol] style The style of this flash. Valid values are +:notice+ (default), +:warn+ and +:error+
    #
    def render_flash_notice(notice, style = :notice)
      render('alchemy/admin/partials/flash', flash_type: style, message: notice)
    end

    # Checks if the given argument is a String or a Page object.
    # If a String is given, it tries to find the page via page_layout
    # Logs a warning if no page is given.
    def page_or_find(page)
      if page.is_a?(String)
        page = Language.current.pages.find_by(page_layout: page)
      end
      if page.blank?
        warning("No Page found for #{page.inspect}")
        return
      else
        page
      end
    end

  end
end
