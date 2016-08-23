module Alchemy
  module DeprecatedPagesHelper
    # All these helper methods are deprecated.
    # They are mixed into Alchemy::PagesHelper but will be removed in the future.

    def preview_mode_code
      ActiveSupport::Deprecation.warn('PageHelper `preview_mode_code` is deprecated and will be removed with Alchemy v4.0. Please use `render "alchemy/preview_mode_code"` in your layout instead.')
      render "alchemy/preview_mode_code"
    end

    def render_meta_data(options = {})
      ActiveSupport::Deprecation.warn('PageHelper `render_meta_data` is deprecated and will be removed with Alchemy v4.0. Please use `render "alchemy/pages/meta_data"` in your view instead.')
      render "alchemy/pages/meta_data", options
    end

    def render_page_title(options = {})
      ActiveSupport::Deprecation.warn('PageHelper `render_page_title` is deprecated and will be removed with Alchemy v4.0. Please use `render "alchemy/pages/meta_data"` in your view instead.')
      return "" if @page.title.blank?
      options = {
        prefix: "",
        separator: ""
      }.update(options)
      title_parts = [options[:prefix]]
      if response.status == 200
        title_parts << @page.title
      else
        title_parts << response.status
      end
      title_parts.join(options[:separator]).html_safe
    end

    def render_title_tag(options = {})
      ActiveSupport::Deprecation.warn('PageHelper `render_title_tag` is deprecated and will be removed with Alchemy v4.0. Please use `render "alchemy/pages/meta_data"` in your view instead.')
      default_options = {
        prefix: "",
        separator: ""
      }
      options = default_options.merge(options)
      content_tag(:title, render_page_title(options))
    end

    def render_meta_tag(options = {})
      ActiveSupport::Deprecation.warn('PageHelper `render_meta_tag` is deprecated and will be removed with Alchemy v4.0. Please use `tag()` instead. (http://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-tag)')
      default_options = {
        name: "",
        default_language: "de",
        content: ""
      }
      options = default_options.merge(options)
      lang = (@page.language.blank? ? options[:default_language] : @page.language.code)
      tag(:meta, name: options[:name], content: options[:content], lang: lang)
    end
  end
end
