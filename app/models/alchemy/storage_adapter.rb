module Alchemy
  class StorageAdapter
    class UnknownAdapterError < StandardError; end

    attr_reader :name, :adapter

    delegate(
      :attachment_url_class,
      :by_file_format_scope,
      :by_file_type_scope,
      :file_extension,
      :file_formats,
      :file_mime_type,
      :file_name,
      :file_size,
      :has_convertible_format?,
      :image_file_extension,
      :image_file_format,
      :image_file_height,
      :image_file_name,
      :image_file_present?,
      :image_file_size,
      :image_file_width,
      :picture_url_class,
      :preloaded_pictures,
      :preprocessor_class,
      :ransackable_associations,
      :ransackable_attributes,
      :rescuable_errors,
      :searchable_alchemy_resource_attributes,
      :set_attachment_name?,
      to: :adapter
    )

    def initialize(name)
      @name = name.to_sym
      @adapter = adapter_class
    end

    def ==(other)
      name == other.to_sym
    end

    def active_storage?
      name == :active_storage
    end

    def dragonfly?
      name == :dragonfly
    end

    def picture_class_methods
      adapter::PictureClassMethods
    end

    def attachment_class_methods
      adapter::AttachmentClassMethods
    end

    private

    def adapter_class
      case name
      when :active_storage
        ActiveStorage
      when :dragonfly
        Dragonfly
      else
        raise UnknownAdapterError,
          "Unknown storage adapter: #{name}. Please use either 'active_storage' or 'dragonfly'."
      end
    end
  end
end
