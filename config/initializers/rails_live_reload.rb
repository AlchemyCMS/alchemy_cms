# frozen_string_literal: true

if defined?(RailsLiveReload)
  RailsLiveReload.configure do |config|
    # Default watched folders & files
    config.watch %r{app/views/.+\.(erb)$}
    config.watch %r{(app|vendor)/(assets|javascript)/\w+/(.+\.(s?css|coffee|js|html|png|jpg)).*}, reload: :always

    # More examples:
    config.watch %r{app/(helpers|components|decorators)/.+\.rb}, reload: :always
    config.watch %r{config/locales/.+\.yml}, reload: :always
  end
end
