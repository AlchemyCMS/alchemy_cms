module Alchemy
  module Upgrader::TwoPointFour

  private
  
    def removed_richmedia_essences_notice
      warn = <<-WARN
We removed the EssenceAudio, EssenceFlash and EssenceVideo essences from Alchemy core!

In order to get the essences back, install the `alchemy-richmedia-essences` gem.

gem 'alchemy-richmedia-essences'

We left the tables in your database, you can simply drop them if you don't use these essences in your project.

drop_table :alchemy_essence_audios
drop_table :alchemy_essence_flashes
drop_table :alchemy_essence_videos

WARN
      todo warn
    end

  end
end
