module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class PictureCounts < StatWidget
          def initialize(style:)
            @style = style
          end

          private

          def title = Alchemy::Picture.model_name.human(count: :many)
          def link = alchemy.admin_pictures_path
          def icon = "multi-image"
          def count = Alchemy::Picture.count
          def infos = number_to_human_size(Alchemy::Picture.sum(&:image_file_size))
        end
      end
    end
  end
end
