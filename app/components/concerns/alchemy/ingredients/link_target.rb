module Alchemy
  module Ingredients
    module LinkTarget
      BLANK_VALUE = "_blank"
      REL_VALUE = "noopener noreferrer"

      def link_rel_value(target)
        if link_target_value(target) == BLANK_VALUE
          REL_VALUE
        end
      end

      def link_target_value(target)
        (target == "blank") ? BLANK_VALUE : target
      end
    end
  end
end
