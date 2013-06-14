module Alchemy
  module ElementsDescription

    class << self
    
      def descriptions
        @@descriptions ||= read_file
      end

      def read_file
        if ::File.exists? "#{::Rails.root}/config/alchemy/elements.yml"
          ::YAML.load_file("#{::Rails.root}/config/alchemy/elements.yml") || []
        else
          raise LoadError, "Could not find elements.yml file! Please run: rails generate alchemy:scaffold"
        end
      rescue TypeError => e
        warn "Your elements.yml is empty."
        []
      end

    end

  end
end
