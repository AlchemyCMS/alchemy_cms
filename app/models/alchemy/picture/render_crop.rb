# frozen_string_literal: true

module Alchemy
  class Picture
    module RenderCrop
      #########################################################################
      # RENDER CROP
      #
      # If an essence_picture content is rendered with settings[:render_crop] = true
      # a requested size would have its aspect ratio enforced even if the user has already
      # - cropped the picture in admin (using settings[:crop] = true)
      # - or selected a render_size (see settings[:sizes])
      #
      # This means the user cropping mask/size selection will be recalculated (see #adjust_crop_area_to_aspect_ratio)
      # according to specified gravity settings (see below).
      #
      # Without { render_crop: true } the above mentioned user cropped/selected sizes would only be resized
      # to fit inside a requested size - with no adjustment of aspect ratio.
      #
      #
      # GRAVITY
      #
      # Gravity is used when adjusting cropping masks.
      # - Default gravity can be overwritten through settings[:gravity]
      # - If settings[:gravity].present? the gravity options will appear for user selection in picture properties
      #   So you can set { gravity: true } to show selection and keep defaults (see #default_gravity).
      # - Gravity can be useful outside of render_cropping eg. for aligning background images (see example below).
      #
      # - OBS: render_crop with gravity = grow will only grow a cropping mask as much as needed to fit aspect ratio.
      #   And if it cannot grow due to original image boundaries and/or restrictions by specified gravity settings
      #   it will actually shrink the crop area instead.
      #   So even if requested size aspect ratio is the same as original it may not grow back to full size
      #   if the cropping mask is not maximum size or gravity settings restrict growth directions etc.
      #   These caveats can be technically difficult to grasp, but should make sense in practise.
      #
      # - Below is a simple setup you can use to test different results
      #   1. Create a render_crop_page and a user_crop_element with a picture.
      #   2. Adjust/move the cropping mask of below element in admin
      #   3. Change gravities in picture_properties or render
      #
      #   # page_layouts.yml
      #   - name: render_crop_page
      #     elements:
      #     - user_crop_element
      #
      #   # elements.yml
      #   - name: user_crop_element
      #     contents:
      #     - name: user_crop_picture
      #       type: EssencePicture
      #       settings:
      #         gravity: true # Allows user to change gravity in picture properties
      #         crop: true
      #         size: 400x200
      #
      #   # elements/_user_crop_element.html.erb
      #   <h1>User crop element</h1>
      #   <%= element_view_for(user_crop_element) do |el| -%>
      #     <%= el.render :user_crop_picture, { size: "200x400", render_crop: true, gravity: {size: 'grow', x: 'center', y: 'center} } %>
      #   <%- end -%>
      #
      #
      # REAL WORLD USE CASE EXAMPLES
      #
      # 1. Reusing and adapting images to different contexts/designs
      # - Lets say you have a blog post with a cropped main image displayed at the top in a wide format.
      # - Then in the blog post list you want to use the blog posts main images for thumbnails.
      # - But you want them in a less wide format => use render_crop to enforce new aspect ratio.
      #
      # 2. Optimizing and aligning images for different screen sizes
      # - Lets say you want a full width banner that starts really wide in desktop.
      # - You use { crop: true, size: 1920x600 } to let the user crop the desktop version in admin.
      # - You set background-size/object-fit: cover and a banner min-height in css
      #   so it fills your div and doesn't get too thin in smaller screens.
      # - You set { gravity: true } to let the user specify the gravities of the banner.
      #   Then set different positioning classes on your DOM element given specified gravity.
      #   so you can use css to adjust the picture position/focus, eg: background-position/object-position.
      # - You render with { render_crop: true, size: "600x400" } on the mobile element version.
      #   Now you have a taller picture version and less redundant image overflowing outside of view.
      #   And so you have reduced the image size and improved page speed.
      #
      # 3. If you want to make something more advanced, you can instantiate view helpers manually:
      #   Alchemy::EssencePictureView.new(content) - and build your own picture tags with different
      #   srcsets for different screen sizes etc.
      #########################################################################

      # Default size gravity is set to "grow" because:
      #
      # 1. It usually makes sense to show as much as possible of an image.
      # Lets say the user uploads a perfectly fine 4:3 image and is then forced to crop it to less tall 16:9
      # as per defined settings. Then in some place you want to render it in 4:3 again => grow back towards original.
      # If the user specifically cropped an image down to hide something => use gravity = shrink instead.
      #
      # 2. If the user has not applied a cropping mask, the original image should be center cropped to fit
      # size aspect ratio, ignoring the boundaries of the rendered cropping mask => this equates to "grow".
      #
      def default_gravity
        { size: "grow", x: "center", y: "center"}
      end

      # Available gravities are available for selection in picture properties
      # if gravity present in settings. Also used to validate gravity method input
      #
      def available_gravities
        {
          size: ["grow", "shrink", "closest_fit"],
          x: ["left", "center", "right"],
          y: ["top", "center", "bottom"],
        }
      end

      # Validates gravity used for render cropping
      #
      def validate_gravity(gravity)
        return if gravity.nil?

        unless gravity.is_a?(Hash)
          raise ArgumentError, "Gravity not a hash"
        end

        gravity.each do |key, val|
          unless available_gravities[key.to_sym]&.include?(val)
            raise ArgumentError, "Invalid gravity option: #{key}: #{val}"
          end
        end
      end

      # Use picture gravity to adjust the cropped area so that it fits the requested size aspect ratio.
      #
      def adjust_crop_area_to_aspect_ratio(size, crop_from, crop_size, gravity)
        old_crop_size = crop_size.clone

        case gravity[:size]
        when "shrink"
          crop_size = shrink_crop_area(size, crop_size)
        when "closest_fit"
          crop_size = grow_crop_area(size, crop_from, crop_size, gravity, true)
        when "grow"
          crop_size = grow_crop_area(size, crop_from, crop_size, gravity)
        end

        crop_from = crop_from_after_crop_area_resize(crop_from, crop_size, old_crop_size, gravity)

        [crop_from, crop_size]
      end

      # Shrink crop area to fit requested size aspect ratio
      #
      def shrink_crop_area(size, crop_size)
        if has_wider_aspect_ratio?(size, crop_size) # => requested wider size, shrink y
          crop_size[:height] = crop_size[:height] * aspect_ratio(crop_size) / aspect_ratio(size)
        else # => shrink x
          crop_size[:width] = crop_size[:width] * aspect_ratio(size) / aspect_ratio(crop_size)
        end

        round_dimensions(crop_size)
      end

      # Attempt to grow crop area to fit requested size aspect ratio.
      # This may not be possible due to the original images finite boundaries.
      # Then this function will actually shrink parts of the crop area instead
      # as needed to fit requested aspect ratio.
      #
      def grow_crop_area(size, crop_from, crop_size, gravity, closest_fit = false)
        max_growth = max_crop_area_growth(crop_from, crop_size)
        wanted_growth = wanted_crop_area_growth(size, crop_size, gravity, closest_fit)
        growth = actual_crop_area_growth(wanted_growth, max_growth)

        if has_wider_aspect_ratio?(size, crop_size) # => requested wider size, grow x
          crop_size[:width] += growth[:left] + growth[:right]
          crop_size[:height] = crop_size[:width] / aspect_ratio(size)
        else # => grow y
          crop_size[:height] += growth[:top] + growth[:bottom]
          crop_size[:width] = crop_size[:height] * aspect_ratio(size)
        end

        round_dimensions(crop_size)
      end

      # Returns the new crop_from position based on crop gravity after the cropped area has been resized
      #
      def crop_from_after_crop_area_resize(crop_from, crop_size, old_crop_size, gravity)
        if old_crop_size[:width] != crop_size[:width]
          case gravity[:x]
          # No adjustment when left
          when "center"
            crop_from[:x] += (old_crop_size[:width] - crop_size[:width]) / 2
          when "right"
            crop_from[:x] += old_crop_size[:width] - crop_size[:width]
          end
        end

        if old_crop_size[:height] != crop_size[:height]
          case gravity[:y]
          # No adjustment when top
          when "center"
            crop_from[:y] += (old_crop_size[:height] - crop_size[:height]) / 2
          when "bottom"
            crop_from[:y] += old_crop_size[:height] - crop_size[:height]
          end
        end

        crop_from
      end

      # Returns the maximum no of pixels the cropping area can grow in each direction
      # based on the size of the original image.
      #
      def max_crop_area_growth(crop_from, crop_size)
        {
          top: crop_from[:y],
          right: image_size[:width] - crop_from[:x] - crop_size[:width],
          bottom: image_size[:height] - crop_from[:y] - crop_size[:height],
          left: crop_from[:x],
        }
      end

      # Returns the amount of pixels we "would like" the cropping area to grow in each direction
      # in order to fit requested size aspect ratio.
      # Not yet taking the original images finite size into account.
      #
      def wanted_crop_area_growth(size, crop_size, gravity, closest_fit = false)
        growth = { top: 0, right: 0, bottom: 0, left: 0 }

        if has_wider_aspect_ratio?(size, crop_size) # => requested wider size, grow x
          new_width = (crop_size[:width] * aspect_ratio(size) / aspect_ratio(crop_size))
          case gravity[:x]
          when "left"
            growth[:right] = new_width - crop_size[:width]
          when "center"
            growth[:left] = (new_width - crop_size[:width]) / 2
            growth[:right] = growth[:left]
          when "right"
            growth[:left] = new_width - crop_size[:width]
          end
        else # => grow y
          new_height = crop_size[:height] * aspect_ratio(crop_size) / aspect_ratio(size)
          case gravity[:y]
          when "top"
            growth[:bottom] = new_height - crop_size[:height]
          when "center"
            growth[:top] = (new_height - crop_size[:height]) / 2
            growth[:bottom] = growth[:top]
          when "bottom"
            growth[:top] = new_height - crop_size[:height]
          end
        end

        closest_fit ? halve_growth(growth) : growth
      end

      # Halve growth for closest fit
      # This will lead to some shrinking in other direction when aspect ratio is re-established
      #
      def halve_growth(growth)
        growth.each do |direction, value|
          growth[direction] = value.to_f / 2
        end

        growth
      end

      # This function gets the actual growth values by comparing the wanted_crop_area_growth
      # against what is possible within the original images boundaries (max_crop_area_growth)
      #
      # The most limited of the non zero wanted growth values will be the upper limit for all directions.
      # As there will only be more than 1 growth direction when centering and to maintain center
      # both (opposite) growth directions have to be equal
      #
      def actual_crop_area_growth(wanted_growth, max_growth)
        possible_growth = {} # Will only contain non zero wanted growth directions
        wanted_growth.reject{ |_d, v| v.zero? }.each do |direction, _value|
          possible_growth[direction] = if wanted_growth[direction] <= max_growth[direction]
            wanted_growth[direction]
          else
            max_growth[direction]
          end
        end

        max_growth_any_direction = possible_growth.values.min || 0

        actual_growth = {}
        wanted_growth.keys.each do |direction|
          actual_growth[direction] = possible_growth[direction] ? max_growth_any_direction : 0
        end

        actual_growth
      end

      # Round to whole pixels
      #
      def round_dimensions(dim)
        dim.each{ |key, val| dim[key] = val.round }
      end

      # Returns the aspect ratio width / height from size hash
      #
      def aspect_ratio(size)
        size[:width].to_f / size[:height]
      end

      # Check if dimensions are wider
      #
      def has_wider_aspect_ratio?(size1, size2)
        aspect_ratio(size1) > aspect_ratio(size2)
      end
    end
  end
end
