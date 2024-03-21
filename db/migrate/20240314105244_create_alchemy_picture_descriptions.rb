class CreateAlchemyPictureDescriptions < ActiveRecord::Migration[7.0]
  class Base < ActiveRecord::Base
    self.abstract_class = true
    self.table_name_prefix = "alchemy_"
  end

  class Site < Base
  end

  class Language < Base
    belongs_to :site, class_name: "Site"
    def self.default = where(site_id: Site.first).find_by(default: true)
  end

  class Picture < Base
    has_many :descriptions, class_name: "PictureDescription"
  end

  class PictureDescription < Base
    belongs_to :picture, class_name: "Picture"
    belongs_to :language, class_name: "Language"
  end

  def change
    create_table :alchemy_picture_descriptions do |t|
      t.belongs_to :picture, null: false, foreign_key: {to_table: :alchemy_pictures}
      t.belongs_to :language, null: false, foreign_key: {to_table: :alchemy_languages}
      t.text :text

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        language = Language.default
        Picture.find_each do |picture|
          picture.descriptions.create!(
            text: picture.description.presence,
            language: language
          )
        end
      end
    end

    remove_column :alchemy_pictures, :description, :text
  end
end
