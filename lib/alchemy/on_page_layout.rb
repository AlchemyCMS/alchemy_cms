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
  #       on_page_layout :news, :do_something_else
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
    # Pass a block or method name in which you have the +@page+ object and can do
    # everything as if you where in a normal controller action.
    #
    # Pass a +Alchemy::PageLayout+ name or +:all+ to
    # call a callback only on specific pages or on all pages.
    #
    def on_page_layout(page_layouts, callback = nil, &block)
      callback = block || callback
      [page_layouts].flatten.each do |page_layout|
        if callback
          OnPageLayout.register_callback(page_layout, callback)
        else
          raise ArgumentError,
            "You need to either pass a block or method name as callback for `on_page_layout`"
        end
      end
    end
  end
end
