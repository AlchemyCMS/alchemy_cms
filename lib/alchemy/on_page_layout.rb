# frozen_string_literal: true

module Alchemy
  # = Provides a DSL to define callbacks run in a before filter on pages show action
  #
  # Use this mixin to add the +on_page_layout+ class method
  # into your +ApplicationController+.
  #
  # Pass a block or method name in which you have the +@page+ object available and can do
  # everything as if you were in a normal controller action.
  #
  # You can pass a +Alchemy::PageLayout+ name, an array of names, or +:all+ to
  # evaluate the callback on either some specific or all the pages.
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
  #       on_page_layout [:standard, :home, :news], :do_something_else
  #
  #       private
  #
  #       def do_something
  #         @contacts = Contact.all
  #         if @page.tag_list.include?('something')
  #           ...
  #         end
  #       end
  #
  #       def do_something_else
  #         ...
  #       end
  #     end
  #
  module OnPageLayout
    # All registered callbacks
    def self.callbacks
      @callbacks
    end

    # Registers a callback for given page layout
    def self.register_callback(page_layout, callback)
      @callbacks ||= {}
      @callbacks[page_layout] ||= []
      @callbacks[page_layout] << callback
    end

    # Define a page layout callback
    #
    # Pass a block or method name in which you have the +@page+ object available and can do
    # everything as if you were in a normal controller action.
    #
    # Pass a +Alchemy::PageLayout+ name, an array of names, or +:all+ to
    # evaluate the callback on either some specific or all the pages.
    #
    def on_page_layout(page_layouts, callback = nil, &block)
      callback = block || callback
      [page_layouts].flatten.each do |page_layout|
        if callback
          OnPageLayout.register_callback(page_layout, callback)
        else
          raise ArgumentError,
            "You need to either pass a block or method name as a callback for `on_page_layout`"
        end
      end
    end
  end
end
