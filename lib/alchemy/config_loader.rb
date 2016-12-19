module Alchemy
  class ConfigLoader
    attr_reader :which

    def initialize(which)
      @which = which.sub(/\.yml$/, '')
    end

    # Reads the config file named +<which>.yml+ from +config/alchemy/+ folder.
    #
    def load_all
      if paths.empty?
        raise LoadError, "Could not find #{which}.yml file! Please run `rails generate alchemy:scaffold`"
      else
        # OPTIMIZE: remove duplicates?
        paths.map(&method(:load_file)).inject(&:+)
      end
    end

    # Returns the path to +<which>.yml+ file
    #
    def file_path
      Rails.root.join relative_path
    end

    def file_name
      "#{which}.yml"
    end

    def relative_path
      Pathname.new('config').join('alchemy', file_name)
    end

    def paths
      @paths ||= candidates.select(&:exist?)
    end

    private

    def load_file(file_path)
      ::YAML.load(ERB.new(File.read(file_path)).result) || []
    end

    def candidates
      engine_roots.map do |root|
        root.join(relative_path)
      end
    end

    def engine_roots
      loaded_engine_instances.map(&:root)
    end

    # TODO: the order here determines precedence. Should we sort the list?
    def loaded_engine_instances
      # The Rails::Application is abstract and has no instance
      Rails::Engine.descendants.
        reject(&:abstract_railtie?).
        map do |engine|
          begin
            engine.instance
          rescue TypeError
            nil # some engines are singletons
          end
        end.
        compact
    end
  end
end
