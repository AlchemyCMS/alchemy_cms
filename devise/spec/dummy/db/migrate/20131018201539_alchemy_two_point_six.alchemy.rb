# This migration comes from alchemy (originally 20130827094554)
# This is a compressed migration for creating all Alchemy 2.6 tables at once.
#
# === Notice
#
# In order to upgrade from an old version of Alchemy, you have to run all migrations from
# each version you missed up to the version you want to upgrade to, before running this migration.
#
class AlchemyTwoPointSix < ActiveRecord::Migration
  def up
    # Do not run if Alchemy tables are already present
    return if table_exists?(:alchemy_pages)

    create_table "alchemy_attachments", :force => true do |t|
      t.string   "name"
      t.string   "file_name"
      t.string   "file_mime_type"
      t.integer  "file_size"
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.text     "cached_tag_list"
      t.string   "file_uid"
    end

    add_index "alchemy_attachments", ["file_uid"], :name => "index_alchemy_attachments_on_file_uid"

    create_table "alchemy_cells", :force => true do |t|
      t.integer  "page_id"
      t.string   "name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "alchemy_contents", :force => true do |t|
      t.string   "name"
      t.string   "essence_type"
      t.integer  "essence_id"
      t.integer  "element_id"
      t.integer  "position"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
      t.integer  "creator_id"
      t.integer  "updater_id"
    end

    add_index "alchemy_contents", ["element_id", "position"], :name => "index_contents_on_element_id_and_position"

    create_table "alchemy_elements", :force => true do |t|
      t.string   "name"
      t.integer  "position"
      t.integer  "page_id"
      t.boolean  "public",          :default => true
      t.boolean  "folded",          :default => false
      t.boolean  "unique",          :default => false
      t.datetime "created_at",                         :null => false
      t.datetime "updated_at",                         :null => false
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.integer  "cell_id"
      t.text     "cached_tag_list"
    end

    add_index "alchemy_elements", ["page_id", "position"], :name => "index_elements_on_page_id_and_position"

    create_table "alchemy_elements_alchemy_pages", :id => false, :force => true do |t|
      t.integer "element_id"
      t.integer "page_id"
    end

    create_table "alchemy_essence_booleans", :force => true do |t|
      t.boolean  "value"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.integer  "creator_id"
      t.integer  "updater_id"
    end

    add_index "alchemy_essence_booleans", ["value"], :name => "index_alchemy_essence_booleans_on_value"

    create_table "alchemy_essence_dates", :force => true do |t|
      t.datetime "date"
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "alchemy_essence_files", :force => true do |t|
      t.integer  "attachment_id"
      t.string   "title"
      t.string   "css_class"
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
    end

    create_table "alchemy_essence_htmls", :force => true do |t|
      t.text     "source"
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "alchemy_essence_links", :force => true do |t|
      t.string   "link"
      t.string   "link_title"
      t.string   "link_target"
      t.string   "link_class_name"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.integer  "creator_id"
      t.integer  "updater_id"
    end

    create_table "alchemy_essence_pictures", :force => true do |t|
      t.integer  "picture_id"
      t.string   "caption"
      t.string   "title"
      t.string   "alt_tag"
      t.string   "link"
      t.string   "link_class_name"
      t.string   "link_title"
      t.string   "css_class"
      t.string   "link_target"
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.string   "crop_from"
      t.string   "crop_size"
      t.string   "render_size"
    end

    create_table "alchemy_essence_richtexts", :force => true do |t|
      t.text     "body"
      t.text     "stripped_body"
      t.boolean  "do_not_index",  :default => false
      t.boolean  "public"
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.datetime "created_at",                       :null => false
      t.datetime "updated_at",                       :null => false
    end

    create_table "alchemy_essence_selects", :force => true do |t|
      t.string   "value"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.integer  "creator_id"
      t.integer  "updater_id"
    end

    add_index "alchemy_essence_selects", ["value"], :name => "index_alchemy_essence_selects_on_value"

    create_table "alchemy_essence_texts", :force => true do |t|
      t.text     "body"
      t.string   "link"
      t.string   "link_title"
      t.string   "link_class_name"
      t.boolean  "public",          :default => false
      t.boolean  "do_not_index",    :default => false
      t.string   "link_target"
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.datetime "created_at",                         :null => false
      t.datetime "updated_at",                         :null => false
    end

    create_table "alchemy_folded_pages", :force => true do |t|
      t.integer "page_id"
      t.integer "user_id"
      t.boolean "folded",  :default => false
    end

    create_table "alchemy_languages", :force => true do |t|
      t.string   "name"
      t.string   "language_code"
      t.string   "frontpage_name"
      t.string   "page_layout",    :default => "intro"
      t.boolean  "public",         :default => false
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.boolean  "default",        :default => false
      t.string   "country_code",   :default => "",      :null => false
      t.integer  "site_id"
    end

    add_index "alchemy_languages", ["language_code", "country_code"], :name => "index_alchemy_languages_on_language_code_and_country_code"
    add_index "alchemy_languages", ["language_code"], :name => "index_alchemy_languages_on_language_code"
    add_index "alchemy_languages", ["site_id"], :name => "index_alchemy_languages_on_site_id"

    create_table "alchemy_legacy_page_urls", :force => true do |t|
      t.string   "urlname",    :null => false
      t.integer  "page_id",    :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "alchemy_legacy_page_urls", ["urlname"], :name => "index_alchemy_legacy_page_urls_on_urlname"

    create_table "alchemy_pages", :force => true do |t|
      t.string   "name"
      t.string   "urlname"
      t.string   "title"
      t.string   "language_code"
      t.boolean  "language_root"
      t.string   "page_layout"
      t.text     "meta_keywords"
      t.text     "meta_description"
      t.integer  "lft"
      t.integer  "rgt"
      t.integer  "parent_id"
      t.integer  "depth"
      t.boolean  "visible",          :default => false
      t.boolean  "public",           :default => false
      t.boolean  "locked",           :default => false
      t.integer  "locked_by"
      t.boolean  "restricted",       :default => false
      t.boolean  "robot_index",      :default => true
      t.boolean  "robot_follow",     :default => true
      t.boolean  "sitemap",          :default => true
      t.boolean  "layoutpage",       :default => false
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.integer  "language_id"
      t.text     "cached_tag_list"
    end

    add_index "alchemy_pages", ["language_id"], :name => "index_pages_on_language_id"
    add_index "alchemy_pages", ["parent_id", "lft"], :name => "index_pages_on_parent_id_and_lft"
    add_index "alchemy_pages", ["urlname"], :name => "index_pages_on_urlname"

    create_table "alchemy_pictures", :force => true do |t|
      t.string   "name"
      t.string   "image_file_name"
      t.integer  "image_file_width"
      t.integer  "image_file_height"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.string   "upload_hash"
      t.text     "cached_tag_list"
      t.string   "image_file_uid"
      t.integer  "image_file_size"
    end

    create_table "alchemy_sites", :force => true do |t|
      t.string   "host"
      t.string   "name"
      t.datetime "created_at",                                  :null => false
      t.datetime "updated_at",                                  :null => false
      t.boolean  "public",                   :default => false
      t.text     "aliases"
      t.boolean  "redirect_to_primary_host"
    end

    add_index "alchemy_sites", ["host", "public"], :name => "alchemy_sites_public_hosts_idx"
    add_index "alchemy_sites", ["host"], :name => "index_alchemy_sites_on_host"

    create_table "alchemy_users", :force => true do |t|
      t.string   "firstname"
      t.string   "lastname"
      t.string   "login"
      t.string   "email"
      t.string   "gender"
      t.string   "roles",                                 :default => "registered"
      t.string   "language"
      t.string   "encrypted_password",     :limit => 128, :default => "",           :null => false
      t.string   "password_salt",          :limit => 128, :default => "",           :null => false
      t.integer  "sign_in_count",                         :default => 0,            :null => false
      t.integer  "failed_attempts",                       :default => 0,            :null => false
      t.datetime "last_request_at"
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.datetime "created_at",                                                      :null => false
      t.datetime "updated_at",                                                      :null => false
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.text     "cached_tag_list"
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
    end

    add_index "alchemy_users", ["email"], :name => "index_alchemy_users_on_email", :unique => true
    add_index "alchemy_users", ["login"], :name => "index_alchemy_users_on_login", :unique => true
    add_index "alchemy_users", ["reset_password_token"], :name => "index_alchemy_users_on_reset_password_token", :unique => true
    add_index "alchemy_users", ["roles"], :name => "index_alchemy_users_on_roles"

    create_table "events", :force => true do |t|
      t.string   "name"
      t.string   "hidden_name"
      t.datetime "starts_at"
      t.datetime "ends_at"
      t.text     "description"
      t.decimal  "entrance_fee", :precision => 6, :scale => 2
      t.boolean  "published"
      t.integer  "location_id"
      t.datetime "created_at",                                 :null => false
      t.datetime "updated_at",                                 :null => false
    end

    create_table "locations", :force => true do |t|
      t.string   "name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "taggings", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "context"
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

    create_table "tags", :force => true do |t|
      t.string "name"
    end

  end
end
