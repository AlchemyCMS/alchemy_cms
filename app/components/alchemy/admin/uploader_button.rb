module Alchemy
  module Admin
    class UploaderButton < ViewComponent::Base
      delegate :alchemy, to: :helpers

      attr_reader :object, :file_attribute, :accept, :dropzone, :redirect_url

      def initialize(object:, file_attribute:, redirect_url:, accept: nil, dropzone: nil, label: nil)
        @object = object
        @file_attribute = file_attribute
        @redirect_url = redirect_url
        @dropzone = dropzone || "#main_content"
        @label = label
        @accept = accept || ((file_types.to_a == ["*"]) ? nil : file_types.map { |type| ".#{type}" }.join(", "))
      end

      def call
        content_tag "alchemy-uploader", "redirect-url": redirect_url, dropzone: do
          form_for [alchemy, :admin, object], html: {multipart: true, class: "upload-button"} do |f|
            safe_join([upload_hash_field(f), file_input(f), upload_label(f)].compact)
          end
        end
      end

      private

      def upload_hash_field(f)
        return unless object.respond_to?(:upload_hash)

        f.hidden_field(:upload_hash, name: "#{f.object_name}[upload_hash]", value: Time.current.hash)
      end

      def file_input(f)
        f.file_field file_attribute,
          class: "fileupload fileupload--field", multiple: true, accept: accept,
          name: "#{f.object_name}[#{file_attribute}]", tabindex: "-1"
      end

      def upload_label(f)
        f.label file_attribute, data: {alchemy_hotkey: "alt+n"} do
          content_tag "sl-tooltip", content: tooltip, placement: "top-start" do
            tag.span class: "icon_button", tabindex: "0" do
              render Alchemy::Admin::Icon.new("upload-2")
            end
          end
        end
      end

      def tooltip
        @label.presence || Alchemy.t(:button_label, scope: [:uploader, object.class.model_name.i18n_key])
      end

      def file_types
        Alchemy.config.uploader.allowed_filetypes[object.class.model_name.collection] || ["*"]
      end
    end
  end
end
