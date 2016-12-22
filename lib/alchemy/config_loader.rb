module Alchemy
  class ConfigLoader
    attr_reader :which

    # Options:
    #   before: path(s) to configs with lowest precedence
    #   after: path(s) to configs with highest precedence
    def initialize(which, opts = {})
      @which = which.sub(/\.yml$/, '')
      @before = Array( opts.fetch(:before) { [] } )
      @after = Array( opts.fetch(:after) { [] } )
    end

    # Reads the config file named +<which>.yml+ from +config/alchemy/+ folder.
    #
    def load_all
      if paths.empty?
        raise LoadError, "Could not find #{which}.yml file! Please run `rails generate alchemy:scaffold`"
      else
        paths.map(&method(:load_file)).reduce(&method(:merge))
      end
    end

    def file_name
      "#{which}.yml"
    end

    def relative_path
      Pathname.new('config').join('alchemy', file_name)
    end

    def paths
      @paths ||= ( @before + candidates + @after).uniq.select(&:exist?)
    end

    private

    def load_file(file_path)
      ::YAML.load(ERB.new(File.read(file_path)).result) || default
    end

    def merge(a, b)
      if which.ends_with?('s')
        # Element::Definitions#definition_by_name will return the first match,
        # but our #paths is ordered by increasing precedence
        b + a
      else
        a.stringify_keys.deep_merge(b.stringify_keys)
      end
    end

    def default
      if which.ends_with?('s')
        []
      else
        {}
      end
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
      Rails::Engine.subclasses.map(&:instance) << Rails.application
    end
  end
end
