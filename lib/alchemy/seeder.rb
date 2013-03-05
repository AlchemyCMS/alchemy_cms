require 'thor/shell/color'

module Alchemy
  class Seeder

    class << self

      # This seed builds the necessary page structure for alchemy in your database.
      # Run the alchemy:db:seed rake task to seed your database.
      def seed!
        create_default_site
        create_root_page
      end

    private

      def color(name)
        case name
        when :green
          Thor::Shell::Color::GREEN
        when :red
          Thor::Shell::Color::RED
        when :yellow
          Thor::Shell::Color::YELLOW
        when :black
          Thor::Shell::Color::BLACK
        when :clear
          Thor::Shell::Color::CLEAR
        else
          ""
        end
      end

      def log(message, type=nil)
        case type
        when :skip
          puts "#{color(:yellow)}== Skipping! #{message}#{color(:clear)}"
        when :error
          puts "#{color(:red)}!! ERROR: #{message}#{color(:clear)}"
        when :message
          puts "#{color(:clear)}#{message}"
        else
          puts "#{color(:green)}== #{message}#{color(:clear)}"
        end
      end

      def desc(message)
        puts "\n#{message}"
        puts "#{'-' * message.length}\n"
      end

      def todo(todo)
        add_todo todo
      end

      def add_todo(todo)
        todos << todo
      end

      def todos
        @@todos ||= []
      end

      def display_todos
        if todos.length > 0
          log "\nTODOS:", :message
          log "------\n", :message
          todos.each_with_index do |todo, i|
            log "\n#{i+1}. ", :message
            log todo, :message
          end
        end
      end

    protected

      def create_default_site
        desc "Creating default site"
        site = Alchemy::Site.find_or_initialize_by_host(
          :name => 'Default Site',
          :host => '*'
        )
        if site.new_record?
          if Alchemy::Language.any?
            site.languages = Alchemy::Language.all
          end
          site.save!
          log "Created default site with default language."
        else
          log "Default site was already present.", :skip
        end
      end

      def create_root_page
        desc "Creating root page"
        root = Alchemy::Page.find_or_initialize_by_name(
          :name => 'Root',
          :do_not_sweep => true
        )
        if root.new_record?
          if root.save!
            log "Created page #{root.name}."
          end
        else
          log "Page #{root.name} was already present.", :skip
        end
      end

    end

  end
end
