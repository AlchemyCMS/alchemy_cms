module Alchemy
  module Upgrader::ThreePointOne
    private

    def alchemy_3_1_todos
      notice = <<-NOTE

TinyMCE default paste behavior changed
--------------------------------------

Text is now always pasted in as plain text. To change this, the user has to
disable it with the toolbar button, as they had to before to enable it.

If you have a custom TinyMCE configuration you have to enable this by adding

  paste_as_text: true

into you custom TinyMCE configuration.

NOTE
      todo notice, 'Alchemy v3.1 changes'
    end

  end
end
