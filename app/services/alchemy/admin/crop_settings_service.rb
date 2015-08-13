class Alchemy::Admin::CropSettingsService

  def initialize(picture_style, options)
    @picture_style = picture_style
    @options       = options
  end

  # Gets the minimum dimensions of the image to be rendered. the database render_dimensions
  # has preference over the image_dimensions parameter.
  #
  def dimensions
    return @dimensions if @dimensions
    @dimensions = dimensions_from_picture_style || dimensions_from_options || dimensions_defaults
    add_missing_dimensions_from_ratio unless dimensions_complete?
    @dimensions
  end

  # Infers the aspect ratio from dimensions or parameters. If you don't want a fixed
  # aspect ratio, don't specify a dimensions or only width or height.
  #
  def ratio
    @ratio ||= ratio_from_dimensions || ratio_from_options || false
  end

  def initial_box
    @initial_box ||= @picture_style.cropping_mask || default_box
  end

  def default_box
    @default_box ||= @picture_style.default_mask(dimensions)
  end

  private

  def dimensions_from_picture_style
    return false unless @picture_style.render_size.present?
    @picture_style.sizes_from_string(@picture_style.render_size)
  end

  def dimensions_from_options
    return false unless @options[:image_size]
    @picture_style.sizes_from_string(@options[:image_size])
  end

  def dimensions_defaults
    { width: 0, height: 0 }
  end

  def dimensions_complete?
    height? && width?
  end

  def height?
    dimensions[:height] != 0
  end

  def width?
    dimensions[:width] != 0
  end

  def ratio_from_dimensions
    return false unless dimensions_complete?
    dimensions[:width].to_f / dimensions[:height].to_f
  end

  def ratio_from_options
    return false unless @options[:fixed_ratio]
    @options[:fixed_ratio].to_f
  end

  def add_missing_dimensions_from_ratio
    return unless ratio
    @dimensions[:height] = height_from_ratio unless height?
    @dimensions[:width]  = width_from_ratio  unless width?
  end

  def height_from_ratio
    (dimensions[:width] / ratio).to_i
  end

  def width_from_ratio
    (dimensions[:height] * ratio).to_i
  end
end
