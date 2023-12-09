module Alchemy
  class LiveReloadWatcher < RailsLiveReload::Watcher
    def root = Alchemy::Engine.root
  end
end
