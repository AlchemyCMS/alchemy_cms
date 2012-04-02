module Alchemy
  module PicturesHelper

    # This helper returns a path to picture for use inside a image_tag helper.
    #
    # Any additional options are passed to the url_helper, so you can add arguments to your url.
    #
    # Example:
    #
    #   <%= image_tag alchemy_picture_path(picture, :size => '320x200', :format => :png) %>
    #
    def alchemy_picture_path(picture, options={})
      defaults = {:format => Alchemy::Config.get(:image_output_format)}
      options = defaults.update(options)
      alchemy.show_picture_path({:id => picture.id, :name => picture.urlname}.merge(options))
    end

  end
end
