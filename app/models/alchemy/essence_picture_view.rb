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
      sizes: []
    }.with_indifferent_access

    def initialize(content, options = {}, html_options = {})
      @content = content
      @options = DEFAULT_OPTIONS.merge(content.settings).merge(options)
      @html_options = html_options
      @essence = content.essence
      @picture = essence.picture
    end

    def render
      return if picture.blank?

      output = caption ? img_tag + caption : img_tag

      if is_linked?
        output = link_to(output, url_for(essence.link), {
          title: essence.link_title.presence,
          target: essence.link_target == "blank" ? "_blank" : nil,
          data: {link_target: essence.link_target.presence}
        })
      end

      if caption
        content_tag(:figure, output, {class: essence.css_class.presence}.merge(html_options))
      else
        output
      end
    end

    private

    def caption
      return unless show_caption?

      @_caption ||= content_tag(:figcaption, essence.caption)
    end

    def img_tag
      @_img_tag ||= image_tag(
        essence.picture_url(options.except(*DEFAULT_OPTIONS.keys)), {
          alt: essence.alt_tag.presence,
          title: essence.title.presence,
          class: caption ? nil : essence.css_class.presence,
          srcset: srcset.join(', ').presence,
          sizes: options[:sizes].join(', ').presence
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
        crop_from, crop_size = srcset_crop_for_size(size)
        width, height = size.split('x')
        url = essence.picture_url(
          size: size,
          crop: @options[:crop],
          crop_from: crop_from,
          crop_size: crop_size
        )
        width.present? ? "#{url} #{width}w" : "#{url} #{height}h"
      end
    end

    # Recalculate cropping to adjust aspect ratio and maintain center for any srcset size
    def srcset_crop_for_size(size)
      crop_size = essence.crop_size.presence

      return [nil, nil] unless @options[:crop].present? && crop_size.present?

      width, height = size.split('x').map(&:to_f)
      crop_width, crop_height = crop_size.split('x').map(&:to_f)

      crop_ratio = (crop_width / crop_height)
      size_ratio = (width.to_f / height)

      # Return same cropping if aspect ratio unchanged
      return essence.crop_from, "#{crop_width}x#{crop_height}" if "%.2f" % crop_ratio == "%.2f" % size_ratio

      crop_from_x, crop_from_y = essence.crop_from.split('x').map(&:to_i)
      new_crop_height, new_crop_width = crop_height, crop_width
      new_crop_from_x, new_crop_from_y = crop_from_x, crop_from_y

      if size_ratio > crop_ratio # new size wider => offset y and reduce height
        new_crop_height = crop_height * (crop_ratio / size_ratio)
        new_crop_from_y = crop_from_y + (crop_height - new_crop_height) / 2
      else # offset x and and reduce width
        new_crop_width = (crop_width * (size_ratio / crop_ratio))
        new_crop_from_x = crop_from_x + (crop_width - new_crop_width) / 2
      end

      new_crop_from = "#{new_crop_from_x.to_i}x#{new_crop_from_y.to_i}"
      new_crop_size = "#{new_crop_width.to_i}x#{new_crop_height.to_i}"

      [new_crop_from, new_crop_size]
    end
  end
end
