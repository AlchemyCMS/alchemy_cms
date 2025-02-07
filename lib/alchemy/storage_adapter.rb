module Alchemy
  class StorageAdapter
    class UnknownAdapterError < StandardError; end

    attr_reader :name, :adapter

    delegate :preprocessor_class,
      :url_class,
      :file_formats,
      :rescuable_errors,
      :has_convertible_format?,
      :image_file_name,
      :image_file_format,
      :image_file_size,
      :image_file_width,
      :image_file_height,
      :image_file_extension,
      to: :adapter

    def initialize(name)
      @name = name.to_sym
      @adapter = adapter_class
    end

    def ==(other)
      name == other.to_sym
    end

    def picture_class_methods
      adapter::PictureClassMethods
    end

    private

    def adapter_class
      case name
      when :active_storage
        require "alchemy/storage_adapter/active_storage"
        Alchemy::StorageAdapter::ActiveStorage
      when :dragonfly
        require "alchemy/storage_adapter/dragonfly"
        Alchemy::StorageAdapter::Dragonfly
      else
        raise UnknownAdapterError,
          "Unknown storage adapter: #{name}. Please use one of: :active_storage or :dragonfly"
      end
    end
  end
end
