module Ddb
  module Controller
    # The Userstamp module, when included into a controller, adds a before filter
    # (named <tt>set_stamper</tt>) and an after filter (name <tt>reset_stamper</tt>).
    # These methods assume a couple of things, but can be re-implemented in your
    # controller to better suite your application.
    #
    # See the documentation for <tt>set_stamper</tt> and <tt>reset_stamper</tt> for
    # specific implementation details.
    module Userstamp
      def self.included(base) # :nodoc:
        base.send           :include, InstanceMethods
        base.before_filter  :set_stamper
        base.after_filter   :reset_stamper
      end

      module InstanceMethods
        private
          # The <tt>set_stamper</tt> method as implemented here assumes a couple
          # of things. First, that you are using a +User+ model as the stamper
          # and second that your controller has a <tt>current_user</tt> method
          # that contains the currently logged in stamper. If either of these
          # are not the case in your application you will want to manually add
          # your own implementation of this method to the private section of
          # the controller where you are including the Userstamp module.
          def set_stamper
            User.stamper = self.current_user
          end

          # The <tt>reset_stamper</tt> method as implemented here assumes that a
          # +User+ model is being used as the stamper. If this is not the case then
          # you will need to manually add your own implementation of this method to
          # the private section of the controller where you are including the
          # Userstamp module.
          def reset_stamper
            User.reset_stamper
          end
        #end private
      end
    end
  end
end

ActionController::Base.send(:include, Ddb::Controller) if defined?(ActionController)