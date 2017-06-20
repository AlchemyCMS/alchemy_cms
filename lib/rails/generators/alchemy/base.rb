require 'rails'

module Alchemy
  module Generators
    class Base < ::Rails::Generators::Base
      class_option :template_engine, type: :string, aliases: '-e', desc: 'Template engine for the views. Available options are "erb", "haml", and "slim".'

      private

      def conditional_template(source, destination)
        files = Dir.glob(destination.gsub(/\.([a-z]+)$/, '*'))
        if files.any?
          ext = File.extname(files.first)[1..-1]

          # If view already exists using a different template engine, change
          # source and destination file names to use that engine.
          if ext != template_engine.to_s
            say_status :warning, "View uses unexpected template engine '#{ext}'.", :cyan
            destination.gsub!(/#{template_engine}$/, ext)
            source.gsub!(/#{template_engine}$/, ext)
          end
        end

        template source, destination
      end

      def template_engine
        # Rails is clever enough to default this to whatever template
        # engine is configured through its generator configuration,
        # but we'll default it to erb anyway, just in case.
        options[:template_engine] || 'erb'
      end

      def load_alchemy_yaml(name)
        YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/alchemy/#{name}")).result, [Regexp], [], true)
      rescue Errno::ENOENT
        puts "\nERROR: Could not read config/alchemy/#{name} file. Please run: rails generate alchemy:scaffold"
      end
    end
  end
end
