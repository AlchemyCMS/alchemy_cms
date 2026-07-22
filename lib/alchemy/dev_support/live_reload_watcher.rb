module Alchemy
  class LiveReloadWatcher < RailsLiveReload::Watcher
    # Directories that can hold files matching the configured watch patterns.
    # Globbing the whole engine root would also walk node_modules, the dummy
    # app's logs and databases and any build caches.
    WATCHED_DIRS = %w[app vendor config/locales]

    def root = Alchemy::Engine.root

    # The inherited implementation tracks every file below the root, although
    # only files matching a watch pattern can ever trigger a reload. The whole
    # tree is serialized to the browser on every change, so it is filtered down
    # to the files that are actually able to match.
    def build_tree
      watched_roots.each do |dir|
        Dir.glob(dir.join("**", "*")).each do |file|
          next unless File.file?(file) && watched?(file)

          files[file] = File.mtime(file).to_i
        end
      end
    end

    private

    # The dummy app sits inside the engine root, so it is covered by this
    # watcher as well.
    def watched_roots
      roots = [root]
      roots << Rails.application.root if Rails.application.root.to_s.start_with?("#{root}/")
      roots.flat_map { |dir| WATCHED_DIRS.map { |path| dir.join(path) } }
    end

    def watched?(file)
      RailsLiveReload.patterns.keys.any? { |pattern| file.match(pattern) }
    end
  end
end
