# frozen_string_literal: true

module Alchemy
  # Renders a picture ingredient view
  class PictureView
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::UrlHelper
    include Rails.application.routes.url_helpers

    attr_reader :ingredient, :html_options, :options, :picture

    DEFAULT_OPTIONS = {
      show_caption: true,
      disable_link: false,
      srcset: [],
      sizes: [],
    }.with_indifferent_access

    def initialize(ingredient, options = {}, html_options = {})
      @ingredient = ingredient
      @options = DEFAULT_OPTIONS.merge(ingredient.settings).merge(options || {})
      @html_options = html_options || {}
      @picture = ingredient.picture
    end

    def render
      return if picture.blank?

      output = caption ? img_tag + caption : img_tag

      if is_linked?
        output = link_to(output, url_for(ingredient.link), {
          title: ingredient.link_title.presence,
          target: ingredient.link_target == "blank" ? "_blank" : nil,
          data: { link_target: ingredient.link_target.presence },
        })
      end

      if caption
        content_tag(:figure, output, { class: ingredient.css_class.presence }.merge(html_options))
      else
        output
      end
    end

    def caption
      return unless show_caption?

      @_caption ||= content_tag(:figcaption, ingredient.caption)
    end

    def src
      ingredient.picture_url(options.except(*DEFAULT_OPTIONS.keys))
    end

    def img_tag
      @_img_tag ||= image_tag(
        src, {
          alt: alt_text,
          title: ingredient.title.presence,
          class: caption ? nil : ingredient.css_class.presence,
          srcset: srcset.join(", ").presence,
          sizes: options[:sizes].join(", ").presence,
        }.merge(caption ? {} : html_options)
      )
    end

    def show_caption?
      options[:show_caption] && ingredient.caption.present?
    end

    def is_linked?
      !options[:disable_link] && ingredient.link.present?
    end

    def srcset
      options[:srcset].map do |size|
        url = ingredient.picture_url(size: size)
        width, height = size.split("x")
        width.present? ? "#{url} #{width}w" : "#{url} #{height}h"
      end
    end

    def alt_text
      ingredient.alt_tag.presence || html_options.delete(:alt) || ingredient.picture.name&.humanize
    end
  end
end
