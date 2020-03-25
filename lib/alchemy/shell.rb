# frozen_string_literal: true
require 'thor/shell/color'

module Alchemy
  # Provides methods for collecting sentences and displaying them
  # in a list on the shell / log
  #
  module Shell
    COLORS = {
      clear: Thor::Shell::Color::CLEAR,
      green: Thor::Shell::Color::GREEN,
      red: Thor::Shell::Color::RED,
      yellow: Thor::Shell::Color::YELLOW
    }.freeze

    def self.silence!
      @silenced = true
    end

    def self.verbose!
      @silenced = false
    end

    def self.silenced?
      @silenced ||= false
    end

    def desc(message)
      unless Alchemy::Shell.silenced?
        puts "\n#{message}"
        puts "#{'-' * message.length}\n"
      end
    end

    def todo(todo, title = '')
      add_todo [title, todo]
    end

    # Adds a sentence to the todos Array
    #
    # @param [String] todo
    #
    def add_todo(todo)
      todos << todo
    end

    # All todos
    #
    # @return [Array]
    #
    def todos
      @@todos ||= []
    end

    # Prints out all the todos
    #
    def display_todos
      return if todos.empty?

      log "\n+---------+", :message
      log "| 📝 TODO |", :message
      log "+---------+\n", :message
      puts "\nWe did most of the work for you, but there are still some things left for you to do."
      todos.each_with_index do |todo, i|
        title = "\n#{i + 1}. #{todo[0]}"
        log title, :message
        puts '=' * title.length
        puts ""
        log todo[1], :message
      end
      puts ""
      puts "============================================================"
      puts "= ✨ Please take a minute and read the notes from above ✨ ="
      puts "============================================================"
      puts ""
    end

    # Prints out the given log message with the color due to its type
    #
    # @param [String] message
    # @param [Symbol] type
    #
    def log(message, type = nil)
      unless Alchemy::Shell.silenced?
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
    end

    private

    # Gives the color string using Thor
    # Used for colorizing the message on the shell
    #
    # @param [String] name
    # @return [String]
    #
    def color(name)
      COLORS[name]
    end
  end
end
