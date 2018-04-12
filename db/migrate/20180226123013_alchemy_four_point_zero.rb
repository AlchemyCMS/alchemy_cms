# frozen_string_literal: true

class AlchemyFourPointZero < ActiveRecord::Migration[5.0]
  def up
    unless table_exists?(:alchemy_attachments)
      create_table :alchemy_attachments do |t|
        t.string "name"
        t.string "file_name"
        t.string "file_mime_type"
        t.integer "file_size"
        t.integer "creator_id"
        t.integer "updater_id"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.text "cached_tag_list"
        t.string "file_uid"
        t.index ["file_uid"], name: "index_alchemy_attachments_on_file_uid"
      end
    end

    unless table_exists?(:alchemy_cells)
      create_table :alchemy_cells do |t|
        t.integer "page_id", null: false
        t.string "name"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.index ["page_id"], name: "index_alchemy_cells_on_page_id"
      end
    end

    unless table_exists?(:alchemy_contents)
      create_table :alchemy_contents do |t|
        t.string "name"
        t.string "essence_type", null: false
        t.integer "essence_id", null: false
        t.integer "element_id", null: false
        t.integer "position"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.integer "creator_id"
        t.integer "updater_id"
        t.index ["element_id", "position"], name: "index_contents_on_element_id_and_position"
        t.index ["essence_id", "essence_type"], name: "index_alchemy_contents_on_essence_id_and_essence_type", unique: true
      end
    end

    unless table_exists?(:alchemy_elements)
      create_table :alchemy_elements do |t|
        t.string "name"
        t.integer "position"
        t.integer "page_id", null: false
        t.boolean "public", default: true
        t.boolean "folded", default: false
        t.boolean "unique", default: false
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.integer "creator_id"
        t.integer "updater_id"
        t.integer "cell_id"
        t.text "cached_tag_list"
        t.integer "parent_element_id"
        t.index ["cell_id"], name: "index_alchemy_elements_on_cell_id"
        t.index ["page_id", "parent_element_id"], name: "index_alchemy_elements_on_page_id_and_parent_element_id"
        t.index ["page_id", "position"], name: "index_elements_on_page_id_and_position"
      end
    end

    unless table_exists?(:alchemy_elements_alchemy_pages)
      create_table :alchemy_elements_alchemy_pages, id: false do |t|
        t.integer "element_id"
        t.integer "page_id"
      end
    end

    unless table_exists?(:alchemy_essence_booleans)
      create_table :alchemy_essence_booleans do |t|
        t.boolean "value"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.integer "creator_id"
        t.integer "updater_id"
        t.index ["value"], name: "index_alchemy_essence_booleans_on_value"
      end
    end

    unless table_exists?(:alchemy_essence_dates)
      create_table :alchemy_essence_dates do |t|
        t.datetime "date"
        t.integer "creator_id"
        t.integer "updater_id"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
      end
    end

    unless table_exists?(:alchemy_essence_files)
      create_table :alchemy_essence_files do |t|
        t.integer "attachment_id"
        t.string "title"
        t.string "css_class"
        t.integer "creator_id"
        t.integer "updater_id"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.string "link_text"
        t.index ["attachment_id"], name: "index_alchemy_essence_files_on_attachment_id"
      end
    end

    unless table_exists?(:alchemy_essence_htmls)
      create_table :alchemy_essence_htmls do |t|
        t.text "source"
        t.integer "creator_id"
        t.integer "updater_id"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
      end
    end

    unless table_exists?(:alchemy_essence_links)
      create_table :alchemy_essence_links do |t|
        t.string "link"
        t.string "link_title"
        t.string "link_target"
        t.string "link_class_name"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.integer "creator_id"
        t.integer "updater_id"
      end
    end

    unless table_exists?(:alchemy_essence_pictures)
      create_table :alchemy_essence_pictures do |t|
        t.integer "picture_id"
        t.string "caption"
        t.string "title"
        t.string "alt_tag"
        t.string "link"
        t.string "link_class_name"
        t.string "link_title"
        t.string "css_class"
        t.string "link_target"
        t.integer "creator_id"
        t.integer "updater_id"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.string "crop_from"
        t.string "crop_size"
        t.string "render_size"
        t.index ["picture_id"], name: "index_alchemy_essence_pictures_on_picture_id"
      end
    end

    unless table_exists?(:alchemy_essence_richtexts)
      create_table :alchemy_essence_richtexts do |t|
        t.text "body"
        t.text "stripped_body"
        t.boolean "public"
        t.integer "creator_id"
        t.integer "updater_id"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
      end
    end

    unless table_exists?(:alchemy_essence_selects)
      create_table :alchemy_essence_selects do |t|
        t.string "value"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.integer "creator_id"
        t.integer "updater_id"
        t.index ["value"], name: "index_alchemy_essence_selects_on_value"
      end
    end

    unless table_exists?(:alchemy_essence_texts)
      create_table :alchemy_essence_texts do |t|
        t.text "body"
        t.string "link"
        t.string "link_title"
        t.string "link_class_name"
        t.boolean "public", default: false
        t.string "link_target"
        t.integer "creator_id"
        t.integer "updater_id"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
      end
    end

    unless table_exists?(:alchemy_folded_pages)
      create_table :alchemy_folded_pages do |t|
        t.integer "page_id", null: false
        t.integer "user_id", null: false
        t.boolean "folded", default: false
        t.index ["page_id", "user_id"], name: "index_alchemy_folded_pages_on_page_id_and_user_id", unique: true
      end
    end

    unless table_exists?(:alchemy_languages)
      create_table :alchemy_languages do |t|
        t.string "name"
        t.string "language_code"
        t.string "frontpage_name"
        t.string "page_layout", default: "intro"
        t.boolean "public", default: false
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.integer "creator_id"
        t.integer "updater_id"
        t.boolean "default", default: false
        t.string "country_code", default: "", null: false
        t.integer "site_id", null: false
        t.string "locale"
        t.index ["language_code", "country_code"], name: "index_alchemy_languages_on_language_code_and_country_code"
        t.index ["language_code"], name: "index_alchemy_languages_on_language_code"
        t.index ["site_id"], name: "index_alchemy_languages_on_site_id"
      end
    end

    unless table_exists?(:alchemy_legacy_page_urls)
      create_table :alchemy_legacy_page_urls do |t|
        t.string "urlname", null: false
        t.integer "page_id", null: false
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.index ["page_id"], name: "index_alchemy_legacy_page_urls_on_page_id"
        t.index ["urlname"], name: "index_alchemy_legacy_page_urls_on_urlname"
      end
    end

    unless table_exists?(:alchemy_pages)
      create_table :alchemy_pages do |t|
        t.string "name"
        t.string "urlname"
        t.string "title"
        t.string "language_code"
        t.boolean "language_root"
        t.string "page_layout"
        t.text "meta_keywords"
        t.text "meta_description"
        t.integer "lft"
        t.integer "rgt"
        t.integer "parent_id"
        t.integer "depth"
        t.boolean "visible", default: false
        t.integer "locked_by"
        t.boolean "restricted", default: false
        t.boolean "robot_index", default: true
        t.boolean "robot_follow", default: true
        t.boolean "sitemap", default: true
        t.boolean "layoutpage", default: false
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.integer "creator_id"
        t.integer "updater_id"
        t.integer "language_id"
        t.text "cached_tag_list"
        t.datetime "published_at"
        t.datetime "public_on"
        t.datetime "public_until"
        t.datetime "locked_at"
        t.index ["language_id"], name: "index_pages_on_language_id"
        t.index ["locked_at", "locked_by"], name: "index_alchemy_pages_on_locked_at_and_locked_by"
        t.index ["parent_id", "lft"], name: "index_pages_on_parent_id_and_lft"
        t.index ["public_on", "public_until"], name: "index_alchemy_pages_on_public_on_and_public_until"
        t.index ["rgt"], name: "index_alchemy_pages_on_rgt"
        t.index ["urlname"], name: "index_pages_on_urlname"
      end
    end

    unless table_exists?(:alchemy_pictures)
      create_table :alchemy_pictures do |t|
        t.string "name"
        t.string "image_file_name"
        t.integer "image_file_width"
        t.integer "image_file_height"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.integer "creator_id"
        t.integer "updater_id"
        t.string "upload_hash"
        t.text "cached_tag_list"
        t.string "image_file_uid"
        t.integer "image_file_size"
        t.string "image_file_format"
      end
    end

    unless table_exists?(:alchemy_sites)
      create_table :alchemy_sites do |t|
        t.string "host"
        t.string "name"
        t.datetime "created_at", null: false, precision: 6
        t.datetime "updated_at", null: false, precision: 6
        t.boolean "public", default: false
        t.text "aliases"
        t.boolean "redirect_to_primary_host"
        t.index ["host", "public"], name: "alchemy_sites_public_hosts_idx"
        t.index ["host"], name: "index_alchemy_sites_on_host"
      end
    end

    unless table_exists?(:taggings)
      create_table :taggings do |t|
        t.integer "tag_id"
        t.string "taggable_type"
        t.integer "taggable_id"
        t.string "tagger_type"
        t.integer "tagger_id"
        t.string "context", limit: 128
        t.datetime "created_at", precision: 6
        t.index ["context"], name: "index_taggings_on_context"
        t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
        t.index ["tag_id"], name: "index_taggings_on_tag_id"
        t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
        t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
        t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
        t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
        t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
        t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
      end
    end

    unless table_exists?(:tags)
      create_table :tags do |t|
        t.string "name"
        t.integer "taggings_count", default: 0
        t.index ["name"], name: "index_tags_on_name", unique: true
      end
    end

    unless foreign_key_exists?(:alchemy_cells, column: :page_id)
      add_foreign_key :alchemy_cells, :alchemy_pages,
        column: :page_id,
        on_update: :cascade,
        on_delete: :cascade,
        name: :alchemy_cells_page_id_fkey
    end

    unless foreign_key_exists?(:alchemy_contents, column: :element_id)
      add_foreign_key :alchemy_contents, :alchemy_elements,
        column: :element_id,
        on_update: :cascade,
        on_delete: :cascade,
        name: :alchemy_contents_element_id_fkey
    end

    unless foreign_key_exists?(:alchemy_elements, column: :page_id)
      add_foreign_key :alchemy_elements, :alchemy_pages,
        column: :page_id,
        on_update: :cascade,
        on_delete: :cascade,
        name: :alchemy_elements_page_id_fkey
    end

    unless foreign_key_exists?(:alchemy_elements, column: :cell_id)
      add_foreign_key :alchemy_elements, :alchemy_cells,
        column: :cell_id,
        on_update: :cascade,
        on_delete: :cascade,
        name: :alchemy_elements_cell_id_fkey
    end
  end

  def down
    drop_table(:alchemy_attachments) if table_exists?(:alchemy_attachments)
    drop_table(:alchemy_cells) if table_exists?(:alchemy_cells)
    drop_table(:alchemy_contents) if table_exists?(:alchemy_contents)
    drop_table(:alchemy_elements) if table_exists?(:alchemy_elements)
    drop_table(:alchemy_elements_alchemy_pages) if table_exists?(:alchemy_elements_alchemy_pages)
    drop_table(:alchemy_essence_booleans) if table_exists?(:alchemy_essence_booleans)
    drop_table(:alchemy_essence_dates) if table_exists?(:alchemy_essence_dates)
    drop_table(:alchemy_essence_files) if table_exists?(:alchemy_essence_files)
    drop_table(:alchemy_essence_htmls) if table_exists?(:alchemy_essence_htmls)
    drop_table(:alchemy_essence_links) if table_exists?(:alchemy_essence_links)
    drop_table(:alchemy_essence_pictures) if table_exists?(:alchemy_essence_pictures)
    drop_table(:alchemy_essence_richtexts) if table_exists?(:alchemy_essence_richtexts)
    drop_table(:alchemy_essence_selects) if table_exists?(:alchemy_essence_selects)
    drop_table(:alchemy_essence_texts) if table_exists?(:alchemy_essence_texts)
    drop_table(:alchemy_folded_pages) if table_exists?(:alchemy_folded_pages)
    drop_table(:alchemy_languages) if table_exists?(:alchemy_languages)
    drop_table(:alchemy_legacy_page_urls) if table_exists?(:alchemy_legacy_page_urls)
    drop_table(:alchemy_pages) if table_exists?(:alchemy_pages)
    drop_table(:alchemy_pictures) if table_exists?(:alchemy_pictures)
    drop_table(:alchemy_sites) if table_exists?(:alchemy_sites)
    drop_table(:taggings) if table_exists?(:taggings)
    drop_table(:tags) if table_exists?(:tags)
  end
end
