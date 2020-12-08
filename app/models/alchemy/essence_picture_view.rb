# frozen_string_literal: true

module Alchemy
  # Renders an essence picture view
  class EssencePictureView
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::UrlHelper
    include Rails.application.routes.url_helpers

    attr_reader :content, :essence, :html_options, :options, :picture

    DEFAULT_OPTIONS = {
      show_caption: true,
      disable_link: false,
      srcset: [],
      sizes: [],
    }.with_indifferent_access

    def initialize(content, options = {}, html_options = {})
      @content = content
      @essence = content.essence
      @picture = essence.picture
      @html_options = html_options

      @options = DEFAULT_OPTIONS.merge(content.settings).merge(options).merge(
        # Get potential user selected render_size so we can calculate crop area
        render_size: @essence.render_size,
        # Set gravity with correct fallbacks and validation through essence gravity method
        gravity: @essence.gravity(options.delete(:gravity))
      )
    end

    def render
      return if picture.blank?

      output = caption ? img_tag + caption : img_tag

      if is_linked?
        output = link_to(output, url_for(essence.link), {
          title: essence.link_title.presence,
          target: essence.link_target == "blank" ? "_blank" : nil,
          data: { link_target: essence.link_target.presence },
        })
      end

      if caption
        content_tag(:figure, output, { class: essence.css_class.presence }.merge(html_options))
      else
        output
      end
    end

    def caption
      return unless show_caption?

      @_caption ||= content_tag(:figcaption, essence.caption)
    end

    def src
      essence.picture_url(options.except(*DEFAULT_OPTIONS.keys))
    end

    def img_tag
      @_img_tag ||= image_tag(
        src, {
          alt: alt_text,
          title: essence.title.presence,
          class: caption ? nil : essence.css_class.presence,
          srcset: srcset.join(", ").presence,
          sizes: options[:sizes].join(", ").presence,
        }.merge(caption ? {} : html_options)
      )
    end

    def show_caption?
      options[:show_caption] && essence.caption.present?
    end

    def is_linked?
      !options[:disable_link] && essence.link.present?
    end

    def srcset
      options[:srcset].map do |size|
        url = essence.picture_url(
          size: size,
          render_size: options[:render_size],
          crop: options[:crop],
          render_crop: options[:render_crop],
          gravity: options[:gravity],
        )
        width, height = size.split("x")
        width.present? ? "#{url} #{width}w" : "#{url} #{height}h"
      end
    end

    def alt_text
      essence.alt_tag.presence || html_options.delete(:alt) || essence.picture.name&.humanize
    end
  end
end
