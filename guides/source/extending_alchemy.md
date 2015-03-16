Extending Alchemy
-----------------

At some point you may come across the need of adding some behavior to
already existing controllers or models, that Alchemy provides. Obviously
you could just copy the files, insert them into your projects and edit
them there, but this isn’t a really clean solution.

-   This section will give you a hint on how to extend existing Alchemy
    files without overriding everything.

endprologue.

### Tell Rails to load our extensions

Tell Rails to load our extensions by adding some lines into
config/application.rb

There should be a Application block where you add this.

<ruby>\
config.to\_prepare do\
 Dir.glob(File.join(File.dirname(*FILE*),
“../app/\***/**\_extension.rb”)) do |e|\
 Rails.env.production? ? require(e) : load(e)\
 end\
end\
</ruby>

If you for some reason aren’t using the rails standard for naming your
environments, you should use something like this:

<ruby>\
config.to\_prepare do\
 Dir.glob(File.join(File.dirname(*FILE*),
“../app/\***/**\_extension.rb”)) do |e|\
 [‘env1’, ‘env2’, ‘env3’].include?(Rails.env) ? require(e) : load(e)\
 end\
end\
</ruby>

### Adding a extension

After you set up the loading for our extensions, we can actually start
making some. Lets assume you want to add a before\_action method to the
Alchemy::PagesController. You go into your host app and add a file in
app/controllers/alchemy/ called pages\_controller\_extension.rb. It’s
important to add the \_extension to the filename so rails will load
them.

Into this file you add the following code:

<ruby>\
Alchemy::PagesController.module\_exec do\
end\
</ruby>

Into this block you can add anything you want your controller to do. As
already mentioned, we want to add a before\_action to this controller
for some show off. It could then look like this:

<ruby>\
Alchemy::PagesController.module\_exec do\
 before\_action :some\_method, only: :show\
end\
</ruby>

The last step is adding some\_method to your ApplicationController. This
is done like you are used to in Rails.
