# frozen_string_literal: true

class AlchemyFourPointFour < ActiveRecord::Migration[5.2]
  def up
    unless table_exists?("alchemy_attachments")
      create_table "alchemy_attachments", force: :cascade do |t|
        t.string "name"
        t.string "file_name"
        t.string "file_mime_type"
        t.integer "file_size"
        t.references "creator"
        t.references "updater"
        t.timestamps null: false
        t.string "file_uid"
        t.index ["file_uid"], name: "index_alchemy_attachments_on_file_uid"
      end
    end

    unless table_exists?("alchemy_contents")
      create_table "alchemy_contents", force: :cascade do |t|
        t.string "name"
        t.references "essence", null: false, polymorphic: true, index: { unique: true }
        t.references "element", null: false
      end
    end

    unless table_exists?("alchemy_elements")
      create_table "alchemy_elements", force: :cascade do |t|
        t.string "name"
        t.integer "position"
        t.references "page", null: false, index: false
        t.boolean "public", default: true
        t.boolean "folded", default: false
        t.boolean "unique", default: false
        t.timestamps null: false
        t.references "creator"
        t.references "updater"
        t.references "parent_element", index: false
        t.boolean "fixed", default: false, null: false
        t.index ["fixed"], name: "index_alchemy_elements_on_fixed"
        t.index ["page_id", "parent_element_id"], name: "index_alchemy_elements_on_page_id_and_parent_element_id"
        t.index ["page_id", "position"], name: "index_elements_on_page_id_and_position"
      end
    end

    unless table_exists?("alchemy_elements_alchemy_pages")
      create_table "alchemy_elements_alchemy_pages", id: false, force: :cascade do |t|
        t.references "element"
        t.references "page"
      end
    end

    unless table_exists?("alchemy_essence_booleans")
      create_table "alchemy_essence_booleans", force: :cascade do |t|
        t.boolean "value"
        t.index ["value"], name: "index_alchemy_essence_booleans_on_value"
      end
    end

    unless table_exists?("alchemy_essence_dates")
      create_table "alchemy_essence_dates", force: :cascade do |t|
        t.datetime "date"
      end
    end

    unless table_exists?("alchemy_essence_files")
      create_table "alchemy_essence_files", force: :cascade do |t|
        t.references "attachment"
        t.string "title"
        t.string "css_class"
        t.string "link_text"
      end
    end

    unless table_exists?("alchemy_essence_htmls")
      create_table "alchemy_essence_htmls", force: :cascade do |t|
        t.text "source"
      end
    end

    unless table_exists?("alchemy_essence_links")
      create_table "alchemy_essence_links", force: :cascade do |t|
        t.string "link"
        t.string "link_title"
        t.string "link_target"
        t.string "link_class_name"
      end
    end

    unless table_exists?("alchemy_essence_pages")
      create_table "alchemy_essence_pages", force: :cascade do |t|
        t.references "page"
      end
    end

    unless table_exists?("alchemy_essence_pictures")
      create_table "alchemy_essence_pictures", force: :cascade do |t|
        t.references "picture"
        t.string "caption"
        t.string "title"
        t.string "alt_tag"
        t.string "link"
        t.string "link_class_name"
        t.string "link_title"
        t.string "css_class"
        t.string "link_target"
        t.string "crop_from"
        t.string "crop_size"
        t.string "render_size"
      end
    end

    unless table_exists?("alchemy_essence_richtexts")
      create_table "alchemy_essence_richtexts", force: :cascade do |t|
        t.text "body"
        t.text "stripped_body"
        t.boolean "public"
      end
    end

    unless table_exists?("alchemy_essence_selects")
      create_table "alchemy_essence_selects", force: :cascade do |t|
        t.string "value"
        t.index ["value"], name: "index_alchemy_essence_selects_on_value"
      end
    end

    unless table_exists?("alchemy_essence_texts")
      create_table "alchemy_essence_texts", force: :cascade do |t|
        t.text "body"
        t.string "link"
        t.string "link_title"
        t.string "link_class_name"
        t.boolean "public", default: false
        t.string "link_target"
      end
    end

    unless table_exists?("alchemy_folded_pages")
      create_table "alchemy_folded_pages", force: :cascade do |t|
        t.references "page", null: false, index: false
        t.references "user", null: false, index: false
        t.boolean "folded", default: false
        t.index ["page_id", "user_id"], name: "index_alchemy_folded_pages_on_page_id_and_user_id", unique: true
      end
    end

    unless table_exists?("alchemy_languages")
      create_table "alchemy_languages", force: :cascade do |t|
        t.string "name"
        t.string "language_code"
        t.string "frontpage_name"
        t.string "page_layout", default: "intro"
        t.boolean "public", default: false
        t.timestamps null: false
        t.references "creator"
        t.references "updater"
        t.boolean "default", default: false
        t.string "country_code", default: "", null: false
        t.references "site", null: false
        t.string "locale"
        t.index ["language_code", "country_code"], name: "index_alchemy_languages_on_language_code_and_country_code"
        t.index ["language_code"], name: "index_alchemy_languages_on_language_code"
      end
    end

    unless table_exists?("alchemy_legacy_page_urls")
      create_table "alchemy_legacy_page_urls", force: :cascade do |t|
        t.string "urlname", null: false
        t.references "page", null: false
        t.timestamps null: false
        t.index ["urlname"], name: "index_alchemy_legacy_page_urls_on_urlname"
      end
    end

    unless table_exists?("alchemy_nodes")
      create_table "alchemy_nodes", force: :cascade do |t|
        t.string "name"
        t.string "title"
        t.string "url"
        t.boolean "nofollow", default: false, null: false
        t.boolean "external", default: false, null: false
        t.boolean "folded", default: false, null: false
        t.references "parent"
        t.integer "lft", null: false
        t.integer "rgt", null: false
        t.integer "depth", default: 0, null: false
        t.references "page"
        t.references "language", null: false
        t.references "creator"
        t.references "updater"
        t.timestamps null: false
        t.references "site", null: false
        t.index ["lft"], name: "index_alchemy_nodes_on_lft"
        t.index ["rgt"], name: "index_alchemy_nodes_on_rgt"
      end
    end

    unless table_exists?("alchemy_pages")
      create_table "alchemy_pages", force: :cascade do |t|
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
        t.references "parent", index: false
        t.integer "depth"
        t.boolean "visible", default: false
        t.integer "locked_by"
        t.boolean "restricted", default: false
        t.boolean "robot_index", default: true
        t.boolean "robot_follow", default: true
        t.boolean "sitemap", default: true
        t.boolean "layoutpage", default: false
        t.timestamps null: false
        t.references "creator"
        t.references "updater"
        t.references "language"
        t.datetime "published_at"
        t.datetime "public_on"
        t.datetime "public_until"
        t.datetime "locked_at"
        t.index ["locked_at", "locked_by"], name: "index_alchemy_pages_on_locked_at_and_locked_by"
        t.index ["parent_id", "lft"], name: "index_pages_on_parent_id_and_lft"
        t.index ["public_on", "public_until"], name: "index_alchemy_pages_on_public_on_and_public_until"
        t.index ["rgt"], name: "index_alchemy_pages_on_rgt"
        t.index ["urlname"], name: "index_pages_on_urlname"
      end
    end

    unless table_exists?("alchemy_pictures")
      create_table "alchemy_pictures", force: :cascade do |t|
        t.string "name"
        t.string "image_file_name"
        t.integer "image_file_width"
        t.integer "image_file_height"
        t.timestamps null: false
        t.references "creator"
        t.references "updater"
        t.string "upload_hash"
        t.string "image_file_uid"
        t.integer "image_file_size"
        t.string "image_file_format"
      end
    end

    unless table_exists?("alchemy_sites")
      create_table "alchemy_sites", force: :cascade do |t|
        t.string "host"
        t.string "name"
        t.timestamps null: false
        t.boolean "public", default: false
        t.text "aliases"
        t.boolean "redirect_to_primary_host"
        t.index ["host", "public"], name: "alchemy_sites_public_hosts_idx"
        t.index ["host"], name: "index_alchemy_sites_on_host"
      end
    end

    unless foreign_key_exists?("alchemy_contents", column: "element_id")
      add_foreign_key "alchemy_contents", "alchemy_elements", column: "element_id", on_update: :cascade, on_delete: :cascade
    end

    unless foreign_key_exists?("alchemy_elements", column: "page_id")
      add_foreign_key "alchemy_elements", "alchemy_pages", column: "page_id", on_update: :cascade, on_delete: :cascade
    end

    unless foreign_key_exists?("alchemy_essence_pages", column: "page_id")
      add_foreign_key "alchemy_essence_pages", "alchemy_pages", column: "page_id"
    end

    unless foreign_key_exists?("alchemy_nodes", column: "language_id")
      add_foreign_key "alchemy_nodes", "alchemy_languages", column: "language_id"
    end

    unless foreign_key_exists?("alchemy_nodes", column: "page_id")
      add_foreign_key "alchemy_nodes", "alchemy_pages", column: "page_id", on_delete: :cascade
    end

    unless foreign_key_exists?("alchemy_nodes", column: "site_id")
      add_foreign_key "alchemy_nodes", "alchemy_sites", column: "site_id", on_delete: :cascade
    end
  end

  def down
    drop_table "alchemy_attachments" if table_exists?("alchemy_attachments")
    drop_table "alchemy_contents" if table_exists?("alchemy_contents")
    drop_table "alchemy_elements" if table_exists?("alchemy_elements")
    drop_table "alchemy_elements_alchemy_pages" if table_exists?("alchemy_elements_alchemy_pages")
    drop_table "alchemy_essence_booleans" if table_exists?("alchemy_essence_booleans")
    drop_table "alchemy_essence_dates" if table_exists?("alchemy_essence_dates")
    drop_table "alchemy_essence_files" if table_exists?("alchemy_essence_files")
    drop_table "alchemy_essence_htmls" if table_exists?("alchemy_essence_htmls")
    drop_table "alchemy_essence_links" if table_exists?("alchemy_essence_links")
    drop_table "alchemy_essence_pages" if table_exists?("alchemy_essence_pages")
    drop_table "alchemy_essence_pictures" if table_exists?("alchemy_essence_pictures")
    drop_table "alchemy_essence_richtexts" if table_exists?("alchemy_essence_richtexts")
    drop_table "alchemy_essence_selects" if table_exists?("alchemy_essence_selects")
    drop_table "alchemy_essence_texts" if table_exists?("alchemy_essence_texts")
    drop_table "alchemy_folded_pages" if table_exists?("alchemy_folded_pages")
    drop_table "alchemy_languages" if table_exists?("alchemy_languages")
    drop_table "alchemy_legacy_page_urls" if table_exists?("alchemy_legacy_page_urls")
    drop_table "alchemy_nodes" if table_exists?("alchemy_nodes")
    drop_table "alchemy_pages" if table_exists?("alchemy_pages")
    drop_table "alchemy_pictures" if table_exists?("alchemy_pictures")
    drop_table "alchemy_sites" if table_exists?("alchemy_sites")
  end
end
