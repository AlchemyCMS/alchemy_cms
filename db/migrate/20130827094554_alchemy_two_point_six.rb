# This is a compressed migration for creating all Alchemy 2.6 tables at once.
#
# === Notice
#
# In order to upgrade from an old version of Alchemy, you have to run all migrations from
# each version you missed up to the version you want to upgrade to, before running this migration.
#
class AlchemyTwoPointSix < ActiveRecord::Migration
  def up

    unless table_exists?('alchemy_attachments')
      create_table "alchemy_attachments" do |t|
        t.string   "name"
        t.string   "file_name"
        t.string   "file_mime_type"
        t.integer  "file_size"
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.text     "cached_tag_list"
        t.string   "file_uid"
      end
      add_index "alchemy_attachments", ["file_uid"], name: "index_alchemy_attachments_on_file_uid"
    end

    unless table_exists?('alchemy_cells')
      create_table "alchemy_cells" do |t|
        t.integer  "page_id"
        t.string   "name"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
      end
    end

    unless table_exists?('alchemy_contents')
      create_table "alchemy_contents" do |t|
        t.string   "name"
        t.string   "essence_type"
        t.integer  "essence_id"
        t.integer  "element_id"
        t.integer  "position"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer  "creator_id"
        t.integer  "updater_id"
      end
      add_index "alchemy_contents", ["element_id", "position"], name: "index_contents_on_element_id_and_position"
    end

    unless table_exists?('alchemy_elements')
      create_table "alchemy_elements" do |t|
        t.string   "name"
        t.integer  "position"
        t.integer  "page_id"
        t.boolean  "public",     default: true
        t.boolean  "folded",     default: false
        t.boolean  "unique",     default: false
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.integer  "cell_id"
        t.text     "cached_tag_list"
      end
      add_index "alchemy_elements", ["page_id", "position"], name: "index_elements_on_page_id_and_position"
    end

    unless table_exists?('alchemy_elements_alchemy_pages')
      create_table "alchemy_elements_alchemy_pages", id: false do |t|
        t.integer "element_id"
        t.integer "page_id"
      end
    end

    unless table_exists?('alchemy_essence_booleans')
      create_table "alchemy_essence_booleans" do |t|
        t.boolean  "value"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer  "creator_id"
        t.integer  "updater_id"
      end
      add_index "alchemy_essence_booleans", ["value"], name: "index_alchemy_essence_booleans_on_value"
    end

    unless table_exists?('alchemy_essence_dates')
      create_table "alchemy_essence_dates" do |t|
        t.datetime "date"
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
      end
    end

    unless table_exists?('alchemy_essence_files')
      create_table "alchemy_essence_files" do |t|
        t.integer  "attachment_id"
        t.string   "title"
        t.string   "css_class"
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
      end
    end

    unless table_exists?('alchemy_essence_htmls')
      create_table "alchemy_essence_htmls" do |t|
        t.text     "source"
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
      end
    end

    unless table_exists?('alchemy_essence_links')
      create_table "alchemy_essence_links" do |t|
        t.string   "link"
        t.string   "link_title"
        t.string   "link_target"
        t.string   "link_class_name"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer  "creator_id"
        t.integer  "updater_id"
      end
    end

    unless table_exists?('alchemy_essence_pictures')
      create_table "alchemy_essence_pictures" do |t|
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
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.string   "crop_from"
        t.string   "crop_size"
        t.string   "render_size"
      end
    end

    unless table_exists?('alchemy_essence_richtexts')
      create_table "alchemy_essence_richtexts" do |t|
        t.text     "body"
        t.text     "stripped_body"
        t.boolean  "do_not_index", default: false
        t.boolean  "public"
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.datetime "created_at",   null: false
        t.datetime "updated_at",   null: false
      end
    end

    unless table_exists?('alchemy_essence_selects')
      create_table "alchemy_essence_selects" do |t|
        t.string   "value"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer  "creator_id"
        t.integer  "updater_id"
      end
      add_index "alchemy_essence_selects", ["value"], name: "index_alchemy_essence_selects_on_value"
    end

    unless table_exists?('alchemy_essence_texts')
      create_table "alchemy_essence_texts" do |t|
        t.text     "body"
        t.string   "link"
        t.string   "link_title"
        t.string   "link_class_name"
        t.boolean  "public",          default: false
        t.boolean  "do_not_index",    default: false
        t.string   "link_target"
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.datetime "created_at",      null: false
        t.datetime "updated_at",      null: false
      end
    end

    unless table_exists?('alchemy_folded_pages')
      create_table "alchemy_folded_pages" do |t|
        t.integer "page_id"
        t.integer "user_id"
        t.boolean "folded",  default: false
      end
    end

    unless table_exists?('alchemy_languages')
      create_table "alchemy_languages" do |t|
        t.string   "name"
        t.string   "language_code"
        t.string   "frontpage_name"
        t.string   "page_layout",    default: "intro"
        t.boolean  "public",         default: false
        t.datetime "created_at",     null: false
        t.datetime "updated_at",     null: false
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.boolean  "default",        default: false
        t.string   "country_code",   default: "", null: false
        t.integer  "site_id"
      end
      add_index "alchemy_languages", ["language_code", "country_code"], name: "index_alchemy_languages_on_language_code_and_country_code"
      add_index "alchemy_languages", ["language_code"], name: "index_alchemy_languages_on_language_code"
      add_index "alchemy_languages", ["site_id"], name: "index_alchemy_languages_on_site_id"
    end

    unless table_exists?('alchemy_legacy_page_urls')
      create_table "alchemy_legacy_page_urls" do |t|
        t.string   "urlname",    null: false
        t.integer  "page_id",    null: false
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
      end
      add_index "alchemy_legacy_page_urls", ["urlname"], name: "index_alchemy_legacy_page_urls_on_urlname"
    end

    unless table_exists?('alchemy_pages')
      create_table "alchemy_pages" do |t|
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
        t.boolean  "visible",      default: false
        t.boolean  "public",       default: false
        t.boolean  "locked",       default: false
        t.integer  "locked_by"
        t.boolean  "restricted",   default: false
        t.boolean  "robot_index",  default: true
        t.boolean  "robot_follow", default: true
        t.boolean  "sitemap",      default: true
        t.boolean  "layoutpage",   default: false
        t.datetime "created_at",   null: false
        t.datetime "updated_at",   null: false
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.integer  "language_id"
        t.text     "cached_tag_list"
      end
      add_index "alchemy_pages", ["language_id"], name: "index_pages_on_language_id"
      add_index "alchemy_pages", ["parent_id", "lft"], name: "index_pages_on_parent_id_and_lft"
      add_index "alchemy_pages", ["urlname"], name: "index_pages_on_urlname"
    end

    unless table_exists?('alchemy_pictures')
      create_table "alchemy_pictures" do |t|
        t.string   "name"
        t.string   "image_file_name"
        t.integer  "image_file_width"
        t.integer  "image_file_height"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer  "creator_id"
        t.integer  "updater_id"
        t.string   "upload_hash"
        t.text     "cached_tag_list"
        t.string   "image_file_uid"
        t.integer  "image_file_size"
      end
    end

    unless table_exists?('alchemy_sites')
      create_table "alchemy_sites" do |t|
        t.string   "host"
        t.string   "name"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.boolean  "public",     default: false
        t.text     "aliases"
        t.boolean  "redirect_to_primary_host"
      end
      add_index "alchemy_sites", ["host", "public"], name: "alchemy_sites_public_hosts_idx"
      add_index "alchemy_sites", ["host"], name: "index_alchemy_sites_on_host"
    end

    unless table_exists?('taggings')
      create_table "taggings" do |t|
        t.integer  "tag_id"
        t.integer  "taggable_id"
        t.string   "taggable_type"
        t.integer  "tagger_id"
        t.string   "tagger_type"
        t.string   "context"
        t.datetime "created_at"
      end
      add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id"
      add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
      create_table "tags" do |t|
        t.string "name"
      end
    end

  end
end
