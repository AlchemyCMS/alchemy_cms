# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110919110451) do

  create_table "attachments", :force => true do |t|
    t.string   "name"
    t.string   "filename"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cells", :force => true do |t|
    t.integer  "page_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contents", :force => true do |t|
    t.string   "name"
    t.string   "essence_type"
    t.integer  "essence_id"
    t.integer  "element_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  add_index "contents", ["element_id", "position"], :name => "index_contents_on_element_id_and_position"

  create_table "elements", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.integer  "page_id"
    t.boolean  "public",     :default => true
    t.boolean  "folded",     :default => false
    t.boolean  "unique",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "cell_id"
  end

  add_index "elements", ["page_id", "position"], :name => "index_elements_on_page_id_and_position"

  create_table "elements_pages", :id => false, :force => true do |t|
    t.integer "element_id"
    t.integer "page_id"
  end

  create_table "essence_audios", :force => true do |t|
    t.integer  "attachment_id"
    t.integer  "width",           :default => 400
    t.integer  "height",          :default => 300
    t.boolean  "show_eq",         :default => true
    t.boolean  "show_navigation", :default => true
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "essence_dates", :force => true do |t|
    t.datetime "date"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "essence_files", :force => true do |t|
    t.integer  "attachment_id"
    t.string   "title"
    t.string   "css_class"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "essence_flashes", :force => true do |t|
    t.integer  "attachment_id"
    t.integer  "width",          :default => 400
    t.integer  "height",         :default => 300
    t.string   "player_version", :default => "9.0.28"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "essence_htmls", :force => true do |t|
    t.text     "source"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "essence_pictures", :force => true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crop_from"
    t.string   "crop_size"
    t.string   "render_size"
  end

  create_table "essence_richtexts", :force => true do |t|
    t.text     "body"
    t.text     "stripped_body"
    t.boolean  "do_not_index",  :default => false
    t.boolean  "public"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "essence_texts", :force => true do |t|
    t.text     "body"
    t.string   "link"
    t.string   "link_title"
    t.string   "link_class_name"
    t.boolean  "public",          :default => false
    t.boolean  "do_not_index",    :default => false
    t.string   "link_target"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "essence_videos", :force => true do |t|
    t.integer  "attachment_id"
    t.integer  "width"
    t.integer  "height"
    t.boolean  "allow_fullscreen", :default => true
    t.boolean  "auto_play",        :default => false
    t.boolean  "show_navigation",  :default => true
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "folded_pages", :force => true do |t|
    t.integer "page_id"
    t.integer "user_id"
    t.boolean "folded",  :default => false
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "frontpage_name"
    t.string   "page_layout",    :default => "intro"
    t.boolean  "public",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.boolean  "default",        :default => false
  end

  add_index "languages", ["code"], :name => "index_languages_on_code"

  create_table "pages", :force => true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "language_id"
  end

  add_index "pages", ["language_id"], :name => "index_pages_on_language_id"
  add_index "pages", ["parent_id", "lft"], :name => "index_pages_on_parent_id_and_lft"
  add_index "pages", ["urlname"], :name => "index_pages_on_urlname"

  create_table "pictures", :force => true do |t|
    t.string   "name"
    t.string   "image_filename"
    t.integer  "image_width"
    t.integer  "image_height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  create_table "users", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "login"
    t.string   "email"
    t.string   "gender"
    t.string   "role",                               :default => "registered"
    t.string   "language"
    t.string   "crypted_password",    :limit => 128, :default => "",           :null => false
    t.string   "password_salt",       :limit => 128, :default => "",           :null => false
    t.integer  "login_count",                        :default => 0,            :null => false
    t.integer  "failed_login_count",                 :default => 0,            :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "persistence_token",                                            :null => false
    t.string   "single_access_token",                                          :null => false
    t.string   "perishable_token",                                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
