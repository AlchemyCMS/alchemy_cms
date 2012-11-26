require 'thor/shell/color'

module Alchemy
  class Seeder

    class << self

      # This seed builds the necessary page structure for alchemy in your database.
      # Run the alchemy:db:seed rake task to seed your database.
      def seed!
        create_default_language
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

      def create_default_language
        desc "Creating default language"
        default_language = Alchemy::Config.get(:default_language)
        lang = Alchemy::Language.find_or_initialize_by_language_code(
          :name => default_language['name'],
          :language_code => default_language['code'],
          :frontpage_name => default_language['frontpage_name'],
          :page_layout => default_language['page_layout'],
          :public => true,
          :default => true
        )
        if lang.new_record?
          if lang.save!
            log "Created language #{lang.name}."
          end
        else
          log "Language #{lang.name} was already present.", :skip
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
