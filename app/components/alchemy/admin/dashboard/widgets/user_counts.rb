module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class UserCounts < StatWidget
          def initialize(style:)
            @style = style
          end

          private

          def link = Alchemy.config.admin_users_path
          def icon = "group"
          def title = Alchemy.user_class.model_name.human(count: :many)
          def count = Alchemy.user_class.count

          def infos
            if Alchemy.config.user_class.respond_to?(:logged_in)
              safe_join([
                number_with_delimiter(Alchemy.config.user_class.logged_in.length),
                t(".online")
              ], " ")
            end
          end
        end
      end
    end
  end
end
