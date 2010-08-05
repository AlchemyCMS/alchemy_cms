# new ruby parser from retoo, that should help extracting "#{_('xxx')}", which is needed especially when parsing haml files
#
#!/usr/bin/ruby
# parser/ruby.rb - look for gettext msg strings in ruby files
# Copyright (C) 2009 Reto Schüttel <reto (ät) schuettel (dot) ch>
# You may redistribute it and/or modify it under the same license terms as Ruby.

require 'rubygems'
require 'ruby_parser'

module RubyGettextExtractor
  extend self

  def parse(file, targets = [])  # :nodoc:
    content = File.read(file)
    parse_string(content, file, targets)
  end

  def parse_string(content, file, targets=[])
    # file is just for information in error messages
    parser = Extractor.new(file, targets)
    parser.run(content)
  end

  def target?(file)  # :nodoc:
    return file =~ /\.rb$/
  end

  class Extractor < RubyParser
    def initialize(filename, targets)
      @filename = filename
      @targets = Hash.new
      @results = []

      targets.each do |a|
        k, v = a
        # things go wrong if k already exists, but this
        # should not happen (according to the gettext doc)
        @targets[k] = a
        @results << a
      end

      super()
    end

    def run(content)
      self.parse(content)
      return @results
    end

    def extract_string(node)
      if node.first == :str
        return node.last
      elsif node.first == :call
        type, recv, meth, args = node

        # node has to be in form of "string"+("other_string")
        return nil unless recv && meth == :+

        # descent recurrsivly to determine the 'receiver' of the string concatination
        # "foo" + "bar" + baz" is
        # ("foo".+("bar")).+("baz")
        first_part = extract_string(recv)

        if args.first == :arglist && args.size == 2
          second_part = extract_string(args.last)

          return nil if second_part.nil?

          return first_part.to_s + second_part.to_s
        else
          raise "uuh?"
        end
      else
        return nil
      end
    end

    def extract_key(args, seperator)
      key = nil
      if args.size == 2
        key = extract_string(args.value)
      else
        # this could be n_("aaa","aaa2",1)
        # all strings arguemnts are extracted and joined with \004 or \000

        arguments = args[1..(-1)]

        res = []
        arguments.each do |a|
          str = extract_string(a)
          # only add strings
          res << str if str
        end

        return nil if res.empty?
        key = res.join(seperator)
      end

      return nil unless key

      key.gsub!("\n", '\n')
      key.gsub!("\t", '\t')
      key.gsub!("\0", '\0')

      return key
    end

    def new_call recv, meth, args = nil
      # we dont care if the method is called on a a object
      if recv.nil?
        if (meth == :_ || meth == :p_ || meth == :N_ || meth == :pgettext)
          key = extract_key(args, "\004")
        elsif meth == :n_
          key = extract_key(args, "\000")
        else
          # skip
        end

        if key
          res = @targets[key]

          unless res
            res = [key]
            @results << res
            @targets[key] = res
          end

          res << "#{@filename}:#{lexer.lineno}"
        end
      end

      super recv, meth, args
    end
  end
end