2.0 (2-17-2008)
    * [Ben  Wyrosdick] - Added a migration helper that gives migration scripts a <tt>userstamps</tt>
                         method.
    * [Marshall Roch]  - Stamping can be temporarily turned off using the 'without_stamps' class
                         method. 
      Example:
        Post.without_stamps do
          post = Post.find(params[:id])
          post.update_attributes(params[:post])
          post.save
        end

    * Models that should receive updates made by 'stampers' now use the acts_as_stampable class
      method. This sets up the belongs_to relationships and also injects private methods for use by
      the individual callback filter methods.

    * Models that are responsible for updating now use the acts_as_stamper class method. This
      injects the stamper= and stamper methods that are thread safe and should be updated per
      request by a controller.

    * The Userstamp module is now meant to be included with one of your project's controllers (the
      Application Controller is recommended). It creates a before filter called 'set_stampers' that
      is responsible for setting all the current Stampers.

1.0 (01-18-2006)
    * Initial Release
