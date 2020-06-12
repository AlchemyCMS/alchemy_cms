# frozen_string_literal: true

module Alchemy
  module Picture::Url
    TRANSFORMATION_OPTIONS = [
      :crop,
      :crop_from,
      :crop_size,
      :flatten,
      :format,
      :quality,
      :size,
      :upsample,
    ]

    # Returns a path to picture for use inside a image_tag helper.
    #
    # Any additional options are passed to the url_helper, so you can add arguments to your url.
    #
    # Example:
    #
    #   <%= image_tag picture.url(size: '320x200', format: 'png') %>
    #
    def url(options = {})
      variant = PictureVariant.new(self).call(options)

      if variant
        variant.url(options.except(*TRANSFORMATION_OPTIONS).merge(name: name))
      end
    end
  end
end
