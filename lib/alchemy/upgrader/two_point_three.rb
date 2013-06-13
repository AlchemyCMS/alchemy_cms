module Alchemy
  module Upgrader::TwoPointThree

  private
  
    def gallery_pictures_change_notice
      note =<<NOTE
We have changed the way Alchemy handles EssencePictures in elements.

It is now possible to have single EssencePictures and galleries side by side in the same element.
All element editor views containing render_picture_editor with option `maximum_amount_of_images => 1` must be changed into render_essence_editor_by_name.
In the yml description of these elements add a new content for this picture.

In order to upgrade your elements in the database run:

rails g alchemy:gallery_pictures_migration

and alter `db/seeds.rb`, so that it contains all elements that have essence pictures.

NOTE
      todo note
    end

  end
end
