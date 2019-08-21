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

ActiveRecord::Schema.define(version: 2019_04_24_075603) do

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
    t.index ["file_uid"], name: "index_alchemy_attachments_on_file_uid"
  end

  create_table "alchemy_cells", force: :cascade do |t|
    t.integer "page_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_alchemy_cells_on_page_id"
  end

  create_table "alchemy_contents", force: :cascade do |t|
    t.string "name"
    t.string "essence_type", null: false
    t.integer "essence_id", null: false
    t.integer "element_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.index ["element_id", "position"], name: "index_contents_on_element_id_and_position"
    t.index ["essence_id", "essence_type"], name: "index_alchemy_contents_on_essence_id_and_essence_type", unique: true
  end

  create_table "alchemy_elements", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.integer "page_id", null: false
    t.boolean "public", default: true
    t.boolean "folded", default: false
    t.boolean "unique", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "cell_id"
    t.integer "parent_element_id"
    t.boolean "fixed", default: false, null: false
    t.index ["cell_id"], name: "index_alchemy_elements_on_cell_id"
    t.index ["fixed"], name: "index_alchemy_elements_on_fixed"
    t.index ["page_id", "parent_element_id"], name: "index_alchemy_elements_on_page_id_and_parent_element_id"
    t.index ["page_id", "position"], name: "index_elements_on_page_id_and_position"
  end

  create_table "alchemy_elements_alchemy_pages", id: false, force: :cascade do |t|
    t.integer "element_id"
    t.integer "page_id"
  end

  create_table "alchemy_essence_booleans", force: :cascade do |t|
    t.boolean "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.index ["value"], name: "index_alchemy_essence_booleans_on_value"
  end

  create_table "alchemy_essence_dates", force: :cascade do |t|
    t.datetime "date"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alchemy_essence_files", force: :cascade do |t|
    t.integer "attachment_id"
    t.string "title"
    t.string "css_class"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "link_text"
    t.index ["attachment_id"], name: "index_alchemy_essence_files_on_attachment_id"
  end

  create_table "alchemy_essence_htmls", force: :cascade do |t|
    t.text "source"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alchemy_essence_links", force: :cascade do |t|
    t.string "link"
    t.string "link_title"
    t.string "link_target"
    t.string "link_class_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
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
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "crop_from"
    t.string "crop_size"
    t.string "render_size"
    t.index ["picture_id"], name: "index_alchemy_essence_pictures_on_picture_id"
  end

  create_table "alchemy_essence_richtexts", force: :cascade do |t|
    t.text "body"
    t.text "stripped_body"
    t.boolean "public"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alchemy_essence_selects", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.index ["value"], name: "index_alchemy_essence_selects_on_value"
  end

  create_table "alchemy_essence_texts", force: :cascade do |t|
    t.text "body"
    t.string "link"
    t.string "link_title"
    t.string "link_class_name"
    t.boolean "public", default: false
    t.string "link_target"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alchemy_folded_pages", force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "user_id", null: false
    t.boolean "folded", default: false
    t.index ["page_id", "user_id"], name: "index_alchemy_folded_pages_on_page_id_and_user_id", unique: true
  end

  create_table "alchemy_languages", force: :cascade do |t|
    t.string "name"
    t.string "language_code"
    t.string "frontpage_name"
    t.string "page_layout", default: "intro"
    t.boolean "public", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "alchemy_legacy_page_urls", force: :cascade do |t|
    t.string "urlname", null: false
    t.integer "page_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_alchemy_legacy_page_urls_on_page_id"
    t.index ["urlname"], name: "index_alchemy_legacy_page_urls_on_urlname"
  end

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
    t.integer "parent_id"
    t.integer "depth"
    t.boolean "visible", default: false
    t.integer "locked_by"
    t.boolean "restricted", default: false
    t.boolean "robot_index", default: true
    t.boolean "robot_follow", default: true
    t.boolean "sitemap", default: true
    t.boolean "layoutpage", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "language_id"
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
  end

  create_table "alchemy_sites", force: :cascade do |t|
    t.string "host"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: false
    t.text "aliases"
    t.boolean "redirect_to_primary_host"
    t.index ["host", "public"], name: "alchemy_sites_public_hosts_idx"
    t.index ["host"], name: "index_alchemy_sites_on_host"
  end

  create_table "alchemy_users", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "login"
    t.string "email"
    t.string "gender"
    t.string "language"
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "password_salt", limit: 128, default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.integer "updater_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "alchemy_roles", default: "member"
    t.index ["alchemy_roles"], name: "index_alchemy_users_on_alchemy_roles"
    t.index ["email"], name: "index_alchemy_users_on_email", unique: true
    t.index ["firstname"], name: "index_alchemy_users_on_firstname"
    t.index ["lastname"], name: "index_alchemy_users_on_lastname"
    t.index ["login"], name: "index_alchemy_users_on_login", unique: true
    t.index ["reset_password_token"], name: "index_alchemy_users_on_reset_password_token", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "hidden_name"
    t.datetime "starts_at"
    t.datetime "ends_at"
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
    t.index ["tag_id", "taggable_id", "taggable_type"], name: "unique_taggings", unique: true
    t.index ["tag_id"], name: "index_gutentag_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type"], name: "index_gutentag_taggings_on_taggable_id_and_taggable_type"
  end

  create_table "gutentag_tags", force: :cascade do |t|
    t.string "name", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_gutentag_tags_on_name", unique: true
    t.index ["taggings_count"], name: "index_gutentag_tags_on_taggings_count"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "alchemy_cells", "alchemy_pages", column: "page_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "alchemy_contents", "alchemy_elements", column: "element_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "alchemy_elements", "alchemy_cells", column: "cell_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "alchemy_elements", "alchemy_pages", column: "page_id", on_update: :cascade, on_delete: :cascade
end
