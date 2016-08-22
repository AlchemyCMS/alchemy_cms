module Alchemy
  module DeprecatedPagesHelper
    # All these helper methods are deprecated.
    # They are mixed into Alchemy::PagesHelper but will be removed in the future.

    def preview_mode_code
      ActiveSupport::Deprecation.warn('PageHelper `preview_mode_code` is deprecated and will be removed with Alchemy v4.0. Please use `render "alchemy/preview_mode_code"` in your layout instead.')
      render "alchemy/preview_mode_code"
    end

  end
end
