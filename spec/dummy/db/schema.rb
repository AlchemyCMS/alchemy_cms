# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_08_091432) do

  create_table "alchemy_attachments", force: :cascade do |t|
    t.string "name"
    t.string "file_name"
    t.string "file_mime_type"
    t.integer "file_size"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_uid"
    t.index ["creator_id"], name: "index_alchemy_attachments_on_creator_id"
    t.index ["file_uid"], name: "index_alchemy_attachments_on_file_uid"
    t.index ["updater_id"], name: "index_alchemy_attachments_on_updater_id"
  end

  create_table "alchemy_contents", force: :cascade do |t|
    t.string "name"
    t.string "essence_type", null: false
    t.integer "essence_id", null: false
    t.integer "element_id", null: false
    t.index ["element_id"], name: "index_alchemy_contents_on_element_id"
    t.index ["essence_type", "essence_id"], name: "index_alchemy_contents_on_essence_type_and_essence_id", unique: true
  end

  create_table "alchemy_elements", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.boolean "public", default: true, null: false
    t.boolean "folded", default: false, null: false
    t.boolean "unique", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "parent_element_id"
    t.boolean "fixed", default: false, null: false
    t.integer "page_version_id", null: false
    t.index ["creator_id"], name: "index_alchemy_elements_on_creator_id"
    t.index ["fixed"], name: "index_alchemy_elements_on_fixed"
    t.index ["page_version_id", "parent_element_id"], name: "idx_alchemy_elements_on_page_version_id_and_parent_element_id"
    t.index ["page_version_id", "position"], name: "idx_alchemy_elements_on_page_version_id_and_position"
    t.index ["updater_id"], name: "index_alchemy_elements_on_updater_id"
  end

  create_table "alchemy_elements_alchemy_pages", id: false, force: :cascade do |t|
    t.integer "element_id"
    t.integer "page_id"
    t.index ["element_id"], name: "index_alchemy_elements_alchemy_pages_on_element_id"
    t.index ["page_id"], name: "index_alchemy_elements_alchemy_pages_on_page_id"
  end

  create_table "alchemy_essence_audios", force: :cascade do |t|
    t.integer "attachment_id"
    t.boolean "controls", default: true, null: false
    t.boolean "autoplay", default: false
    t.boolean "loop", default: false, null: false
    t.boolean "muted", default: false, null: false
    t.index ["attachment_id"], name: "index_alchemy_essence_audios_on_attachment_id"
  end

  create_table "alchemy_essence_booleans", force: :cascade do |t|
    t.boolean "value"
    t.index ["value"], name: "index_alchemy_essence_booleans_on_value"
  end

  create_table "alchemy_essence_dates", force: :cascade do |t|
    t.datetime "date"
  end

  create_table "alchemy_essence_files", force: :cascade do |t|
    t.integer "attachment_id"
    t.string "title"
    t.string "css_class"
    t.string "link_text"
    t.index ["attachment_id"], name: "index_alchemy_essence_files_on_attachment_id"
  end

  create_table "alchemy_essence_headlines", force: :cascade do |t|
    t.text "body"
    t.integer "level"
    t.integer "size"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "alchemy_essence_htmls", force: :cascade do |t|
    t.text "source"
  end

  create_table "alchemy_essence_links", force: :cascade do |t|
    t.string "link"
    t.string "link_title"
    t.string "link_target"
    t.string "link_class_name"
  end

  create_table "alchemy_essence_nodes", force: :cascade do |t|
    t.integer "node_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_alchemy_essence_nodes_on_node_id"
  end

  create_table "alchemy_essence_pages", force: :cascade do |t|
    t.integer "page_id"
    t.index ["page_id"], name: "index_alchemy_essence_pages_on_page_id"
  end

  create_table "alchemy_essence_pictures", force: :cascade do |t|
    t.integer "picture_id"
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
    t.index ["picture_id"], name: "index_alchemy_essence_pictures_on_picture_id"
  end

  create_table "alchemy_essence_richtexts", force: :cascade do |t|
    t.text "body"
    t.text "stripped_body"
    t.boolean "public", default: false, null: false
    t.text "sanitized_body"
  end

  create_table "alchemy_essence_selects", force: :cascade do |t|
    t.string "value"
    t.index ["value"], name: "index_alchemy_essence_selects_on_value"
  end

  create_table "alchemy_essence_texts", force: :cascade do |t|
    t.text "body"
    t.string "link"
    t.string "link_title"
    t.string "link_class_name"
    t.boolean "public", default: false, null: false
    t.string "link_target"
  end

  create_table "alchemy_essence_videos", force: :cascade do |t|
    t.integer "attachment_id"
    t.string "width"
    t.string "height"
    t.boolean "allow_fullscreen", default: true, null: false
    t.boolean "autoplay", default: false, null: false
    t.boolean "controls", default: true, null: false
    t.boolean "loop", default: false, null: false
    t.boolean "muted", default: false, null: false
    t.string "preload"
    t.index ["attachment_id"], name: "index_alchemy_essence_videos_on_attachment_id"
  end

  create_table "alchemy_folded_pages", force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "user_id", null: false
    t.boolean "folded", default: false, null: false
    t.index ["page_id", "user_id"], name: "index_alchemy_folded_pages_on_page_id_and_user_id", unique: true
  end

  create_table "alchemy_ingredients", force: :cascade do |t|
    t.integer "element_id", null: false
    t.string "type", null: false
    t.string "role", null: false
    t.text "value"
    t.json "data"
    t.string "related_object_type"
    t.integer "related_object_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["element_id", "role"], name: "index_alchemy_ingredients_on_element_id_and_role", unique: true
    t.index ["element_id"], name: "index_alchemy_ingredients_on_element_id"
    t.index ["related_object_id", "related_object_type"], name: "idx_alchemy_ingredient_relation"
    t.index ["type"], name: "index_alchemy_ingredients_on_type"
  end

  create_table "alchemy_languages", force: :cascade do |t|
    t.string "name"
    t.string "language_code"
    t.string "frontpage_name"
    t.string "page_layout", default: "intro"
    t.boolean "public", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.boolean "default", default: false, null: false
    t.string "country_code", default: "", null: false
    t.integer "site_id", null: false
    t.string "locale"
    t.index ["creator_id"], name: "index_alchemy_languages_on_creator_id"
    t.index ["language_code", "country_code"], name: "index_alchemy_languages_on_language_code_and_country_code"
    t.index ["language_code"], name: "index_alchemy_languages_on_language_code"
    t.index ["site_id"], name: "index_alchemy_languages_on_site_id"
    t.index ["updater_id"], name: "index_alchemy_languages_on_updater_id"
  end

  create_table "alchemy_legacy_page_urls", force: :cascade do |t|
    t.string "urlname", null: false
    t.integer "page_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_alchemy_legacy_page_urls_on_page_id"
    t.index ["urlname"], name: "index_alchemy_legacy_page_urls_on_urlname"
  end

  create_table "alchemy_nodes", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "url"
    t.boolean "nofollow", default: false, null: false
    t.boolean "external", default: false, null: false
    t.boolean "folded", default: false, null: false
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "page_id"
    t.integer "language_id", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "menu_type", null: false
    t.index ["creator_id"], name: "index_alchemy_nodes_on_creator_id"
    t.index ["language_id"], name: "index_alchemy_nodes_on_language_id"
    t.index ["lft"], name: "index_alchemy_nodes_on_lft"
    t.index ["page_id"], name: "index_alchemy_nodes_on_page_id"
    t.index ["parent_id"], name: "index_alchemy_nodes_on_parent_id"
    t.index ["rgt"], name: "index_alchemy_nodes_on_rgt"
    t.index ["updater_id"], name: "index_alchemy_nodes_on_updater_id"
  end

  create_table "alchemy_page_versions", force: :cascade do |t|
    t.integer "page_id", null: false
    t.datetime "public_on"
    t.datetime "public_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_alchemy_page_versions_on_page_id"
    t.index ["public_on", "public_until"], name: "index_alchemy_page_versions_on_public_on_and_public_until"
  end

  create_table "alchemy_pages", force: :cascade do |t|
    t.string "name"
    t.string "urlname"
    t.string "title"
    t.string "language_code"
    t.boolean "language_root", default: false, null: false
    t.string "page_layout"
    t.text "meta_keywords"
    t.text "meta_description"
    t.integer "lft"
    t.integer "rgt"
    t.integer "parent_id"
    t.integer "depth"
    t.integer "locked_by"
    t.boolean "restricted", default: false, null: false
    t.boolean "robot_index", default: true, null: false
    t.boolean "robot_follow", default: true, null: false
    t.boolean "sitemap", default: true, null: false
    t.boolean "layoutpage", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "language_id", null: false
    t.datetime "published_at"
    t.datetime "legacy_public_on"
    t.datetime "legacy_public_until"
    t.datetime "locked_at"
    t.index ["creator_id"], name: "index_alchemy_pages_on_creator_id"
    t.index ["language_id"], name: "index_alchemy_pages_on_language_id"
    t.index ["locked_at", "locked_by"], name: "index_alchemy_pages_on_locked_at_and_locked_by"
    t.index ["parent_id", "lft"], name: "index_pages_on_parent_id_and_lft"
    t.index ["rgt"], name: "index_alchemy_pages_on_rgt"
    t.index ["updater_id"], name: "index_alchemy_pages_on_updater_id"
    t.index ["urlname"], name: "index_pages_on_urlname"
  end

  create_table "alchemy_picture_thumbs", force: :cascade do |t|
    t.integer "picture_id", null: false
    t.string "signature", null: false
    t.text "uid", null: false
    t.index ["picture_id"], name: "index_alchemy_picture_thumbs_on_picture_id"
    t.index ["signature"], name: "index_alchemy_picture_thumbs_on_signature", unique: true
  end

  create_table "alchemy_pictures", force: :cascade do |t|
    t.string "name"
    t.string "image_file_name"
    t.integer "image_file_width"
    t.integer "image_file_height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.string "upload_hash"
    t.string "image_file_uid"
    t.integer "image_file_size"
    t.string "image_file_format"
    t.index ["creator_id"], name: "index_alchemy_pictures_on_creator_id"
    t.index ["updater_id"], name: "index_alchemy_pictures_on_updater_id"
  end

  create_table "alchemy_sites", force: :cascade do |t|
    t.string "host"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: false, null: false
    t.text "aliases"
    t.boolean "redirect_to_primary_host", default: false, null: false
    t.index ["host", "public"], name: "alchemy_sites_public_hosts_idx"
    t.index ["host"], name: "index_alchemy_sites_on_host"
  end

  create_table "bookings", force: :cascade do |t|
    t.date "from"
    t.date "until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dummy_models", force: :cascade do |t|
    t.string "data"
  end

  create_table "dummy_users", force: :cascade do |t|
    t.string "email"
    t.string "password"
    t.index ["email"], name: "index_dummy_users_on_email"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "hidden_name"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.time "lunch_starts_at"
    t.time "lunch_ends_at"
    t.text "description"
    t.decimal "entrance_fee", precision: 6, scale: 2
    t.boolean "published"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gutentag_taggings", force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_gutentag_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id", "tag_id"], name: "unique_taggings", unique: true
    t.index ["taggable_type", "taggable_id"], name: "index_gutentag_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "gutentag_tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0, null: false
    t.index ["name"], name: "index_gutentag_tags_on_name", unique: true
    t.index ["taggings_count"], name: "index_gutentag_tags_on_taggings_count"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series", force: :cascade do |t|
    t.string "name"
  end

  add_foreign_key "alchemy_contents", "alchemy_elements", column: "element_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "alchemy_elements", "alchemy_page_versions", column: "page_version_id", on_delete: :cascade
  add_foreign_key "alchemy_essence_nodes", "alchemy_nodes", column: "node_id"
  add_foreign_key "alchemy_essence_pages", "alchemy_pages", column: "page_id"
  add_foreign_key "alchemy_ingredients", "alchemy_elements", column: "element_id", on_delete: :cascade
  add_foreign_key "alchemy_nodes", "alchemy_languages", column: "language_id"
  add_foreign_key "alchemy_nodes", "alchemy_pages", column: "page_id", on_delete: :cascade
  add_foreign_key "alchemy_page_versions", "alchemy_pages", column: "page_id", on_delete: :cascade
  add_foreign_key "alchemy_pages", "alchemy_languages", column: "language_id"
  add_foreign_key "alchemy_picture_thumbs", "alchemy_pictures", column: "picture_id"
end
