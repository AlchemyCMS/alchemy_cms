module Alchemy
  module BaseHelper

    # An alias for truncate.
    # Left here for downwards compatibilty.
    def shorten(text, length)
      text.truncate(:length => length)
    end

    # Returns @language set in the action (e.g. Page.show)
    def current_language
      ActiveSupport::Deprecation.warn('This Proxy-method is deprecated. Please use @language directly.')
      if @language.nil?
        warning('@language is not set')
        nil
      else
        @language
      end
    end

    def parse_sitemap_name(page)
      if multi_language?
        pathname = "/#{session[:language_code]}/#{page.urlname}"
      else
        pathname = "/#{page.urlname}"
      end
      pathname
    end

    # Logs a message in the Rails logger (warn level) and optionally displays an error message to the user.
    def warning(message, text = nil)
      logger.warn %(\n
      ++++ WARNING: #{message}! from: #{caller.first}\n
                  )
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
      result = Array.new
      result << current
      while current = current.parent
        result << current
      end
      return result.reverse
    end

    # Returns a hash with urlname for each url level.
    # I.e.: +{:level1 => 'company', :level2 => 'history'}+
    def params_for_nested_url(page = nil)
      page ||= @page
      raise ArgumentError if page.nil?
      nested_urL_params = {}
      page_bread_crumb = breadcrumb(page)
      urlnames = page_bread_crumb[2..page_bread_crumb.length-2].collect(&:urlname)
      urlnames.each_with_index do |urlname, i|
        nested_urL_params["level#{i+1}"] = urlname
      end
      nested_urL_params.symbolize_keys
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

  end
end
