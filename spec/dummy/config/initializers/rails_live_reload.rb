# frozen_string_literal: true

if defined?(RailsLiveReload)
  RailsLiveReload.configure do |config|
    # Default watched folders & files
    config.watch %r{app/views/.+\.(erb)$}
    config.watch %r{(app|vendor)/(assets|javascript)/\w+/(.+\.(s?css|coffee|js|html|png|jpg)).*}, reload: :always

    # More examples:
    config.watch %r{app/(helpers|components|decorators)/.+\.rb}, reload: :always
    config.watch %r{config/locales/.+\.yml}, reload: :always

    # Listen anchors its own log/ and tmp/ defaults at each watched root, so a
    # watcher rooted above the application still sees them. Any write in the
    # watched tree wakes the watcher and re-checks every connected browser, so
    # directories written while merely serving a request have to be ignored.
    # Everything below spec/ is ignored except the dummy app's own sources, so
    # that its logs, databases and uploads cannot wake the watcher.
    if config.respond_to?(:ignore)
      config.ignore %r{^spec/(?!dummy/(app|config/locales)/)}
      config.ignore %r{^node_modules/}
      config.ignore %r{^(db|storage|coverage)/}
    end
  end
end
