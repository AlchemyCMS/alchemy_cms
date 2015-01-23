module Alchemy
  module Upgrader::ThreePointOne
    private

    def alchemy_3_1_todos
      notice = <<-NOTE

JSON API moved into '/api' namespace
------------------------------------

The JSON API now lives under /api and not as additional format to default controllers.
Also the serialization changed into more useful payload.

Please upgrade your API calls to use the new /api namespace.


TinyMCE default paste behavior changed
--------------------------------------

Text is now always pasted in as plain text. To change this, the user has to
disable it with the toolbar button, as they had to before to enable it.

If you have a custom TinyMCE configuration you have to enable this by adding

  paste_as_text: true

into you custom TinyMCE configuration.


TinyMCE toolbar config has changed
----------------------------------

The 'toolbar' configuration now takes an array of toolbar rows, instead of
using 'toolbarN' syntax. Please update your TinyMCE configuration.

Visit http://www.tinymce.com/wiki.php/Configuration:toolbar for more information.


ApplicationController patch removed
-----------------------------------

If you have controllers that loads Alchemy content or uses Alchemy helpers in
the views (i.e. `render_navigation` or `render_elements`) you should

  include Alchemy::ControllerActions

in these controllers.


NOTE
      todo notice, 'Alchemy v3.1 changes'
    end
  end
end
