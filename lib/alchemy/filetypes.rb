# frozen_string_literal: true

module Alchemy
  module Filetypes
    ARCHIVE_FILE_TYPES = ["application/zip", "application/x-rar"]

    AUDIO_FILE_TYPES = [
      "audio/mpeg",
      "audio/mp4",
      "audio/wav",
      "audio/x-wav"
    ]

    IMAGE_FILE_TYPES = [
      "image/gif",
      "image/jpeg",
      "image/png",
      "image/svg+xml",
      "image/tiff",
      "image/x-psd"
    ]

    VCARD_FILE_TYPES = ["text/x-vcard", "application/vcard"]

    VIDEO_FILE_TYPES = [
      "application/x-flash-video",
      "video/x-flv",
      "video/mp4",
      "video/mpeg",
      "video/quicktime",
      "video/x-msvideo",
      "video/x-ms-wmv"
    ]

    TEXT_FILE_TYPES = [
      "application/rtf",
      "text/plain"
    ]

    EXCEL_FILE_TYPES = [
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "application/vnd.ms-excel",
      "text/csv"
    ]
  end
end
