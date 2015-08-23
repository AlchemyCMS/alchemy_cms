module Alchemy

  # = Adds before filter to pages show action
  #
  # Use this mixin to add the +on_page_layout+ class method
  # into your +ApplicationController+.
  #
  # Pass a block or method name in which you have the +@page+ object and can do
  # everything as if you where in a normal controller action.
  #
  # Pass a +Alchemy::PageLayout+ name or +:all+ to
  # call this callback only on specific pages or all pages.
  #
  # == Example:
  #
  #     class ApplicationController < ActionController::Base
  #       extend Alchemy::OnPageLayout
  #
  #       on_page_layout :all do
  #         @my_stuff = Stuff.all
  #       end
  #
  #       on_page_layout :contact, :do_something
  #
  #       private
  #
  #       def do_something
  #         @contacts = Contact.all
  #         if @page.tag_list.include?('something')
  #           do_something
  #         end
  #       end
  #     end
  #
  module OnPageLayout
    mattr_accessor(:callbacks) { Hash.new }

    def on_page_layout(page_layout, callback = nil, &block)
      @@callbacks[page_layout] ||= []
      if block_given?
        @@callbacks[page_layout] << block
      elsif callback
        @@callbacks[page_layout] << callback
      else
        raise "You need to either pass a block or method name as callback for `on_page_layout`"
      end
    end
  end
end
