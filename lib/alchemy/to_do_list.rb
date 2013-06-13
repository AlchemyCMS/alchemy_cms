# encoding: utf-8
require 'thor/shell/color'

module Alchemy

  # Provides methods for collecting sentences and displaying them
  # in a ordered ToDo list on the shell / log 
  #
  module ToDoList

    def todo(todo)
      add_todo todo
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
      if todos.length > 0
        log "\nTODOS:", :message
        log "------\n", :message
        todos.each_with_index do |todo, i|
          log "\n#{i+1}. ", :message
          log todo, :message
        end
      end
    end

    # Logs the given todo message with the color due to the message type
    #
    # @param [String] message
    # @param [Symbol] type
    #
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

  private

    # Colorizes the message using Thor
    #
    # @param [String] name
    # @return [String]
    #
    def color(name)
      color_const = name.to_s.upcase
      if Thor::Shell::Color.const_defined?(color_const)
        "Thor::Shell::Color::#{color_const}".constantize
      else
        ""
      end
    end

  end
end
