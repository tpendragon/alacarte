# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130917194130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dods", force: true do |t|
    t.boolean "visible",     default: true
    t.string  "title",                           null: false
    t.string  "url",                             null: false
    t.string  "startdate",   default: "unknown"
    t.string  "enddate",     default: "unknown"
    t.string  "provider",    default: "",        null: false
    t.string  "providerurl"
    t.boolean "proxy",       default: false
    t.string  "brief"
    t.text    "descr"
    t.string  "fulltxt"
    t.string  "illreq"
    t.string  "fssub"
    t.string  "other"
  end

  add_index "dods", ["title"], name: "index_dods_on_title", using: :btree

  create_table "guides", force: true do |t|
    t.string   "guide_name",                  null: false
    t.integer  "node_id"
    t.datetime "updated_at"
    t.string   "created_by",  default: ""
    t.boolean  "published",   default: false
    t.text     "description"
    t.text     "relateds"
  end

  add_index "guides", ["node_id"], name: "index_guides_on_resource_id", using: :btree

  create_table "guides_masters", id: false, force: true do |t|
    t.integer "guide_id"
    t.integer "master_id"
  end

  add_index "guides_masters", ["guide_id"], name: "index_guides_masters_on_guide_id", using: :btree
  add_index "guides_masters", ["master_id"], name: "index_guides_masters_on_master_id", using: :btree

  create_table "guides_subjects", id: false, force: true do |t|
    t.integer "guide_id"
    t.integer "subject_id"
  end

  add_index "guides_subjects", ["guide_id"], name: "index_guides_subjects_on_guide_id", using: :btree
  add_index "guides_subjects", ["subject_id"], name: "index_guides_subjects_on_subject_id", using: :btree

  create_table "guides_users", id: false, force: true do |t|
    t.integer "guide_id"
    t.integer "user_id"
  end

  add_index "guides_users", ["guide_id"], name: "index_guides_users_on_guide_id", using: :btree
  add_index "guides_users", ["user_id"], name: "index_guides_users_on_user_id", using: :btree

  create_table "locals", force: true do |t|
    t.string  "banner_url"
    t.string  "logo_url"
    t.string  "styles"
    t.string  "lib_name"
    t.string  "lib_url"
    t.string  "univ_name"
    t.string  "univ_url"
    t.text    "footer"
    t.text    "image_map"
    t.string  "ica_page_title",   default: "Get Help with a Class"
    t.string  "guide_page_title", default: "Get Help with a Subject"
    t.integer "logo_width"
    t.integer "logo_height"
    t.string  "proxy"
    t.string  "admin_email_to"
    t.string  "admin_email_from"
    t.text    "left_box"
    t.string  "js_link"
    t.text    "meta"
    t.text    "tracking"
    t.text    "guide_box"
    t.text    "right_box"
  end

  create_table "masters", force: true do |t|
    t.string "value", null: false
  end

  create_table "nodes", force: true do |t|
    t.string   "module_title", default: "",    null: false
    t.string   "label"
    t.text     "content"
    t.text     "more_info"
    t.string   "created_by"
    t.datetime "updated_at"
    t.boolean  "global",       default: false
    t.string   "slug"
    t.boolean  "published",    default: false
  end

  create_table "nodes_users", id: false, force: true do |t|
    t.integer "node_id"
    t.integer "user_id"
  end

  add_index "nodes_users", ["node_id", "user_id"], name: "index_resources_users_on_resource_id_and_user_id", using: :btree

  create_table "pages", force: true do |t|
    t.boolean  "published",   default: false
    t.string   "sect_num"
    t.string   "course_name",                 null: false
    t.string   "term",        default: ""
    t.string   "year",        default: ""
    t.string   "campus",      default: ""
    t.string   "course_num"
    t.text     "description"
    t.datetime "updated_at"
    t.date     "created_on"
    t.boolean  "archived",    default: false
    t.integer  "node_id"
    t.string   "created_by"
    t.text     "relateds"
  end

  add_index "pages", ["published"], name: "published", using: :btree

  create_table "pages_subjects", id: false, force: true do |t|
    t.integer "page_id"
    t.integer "subject_id"
  end

  add_index "pages_subjects", ["page_id"], name: "index_pages_subjects_on_page_id", using: :btree
  add_index "pages_subjects", ["subject_id"], name: "index_pages_subjects_on_subject_id", using: :btree

  create_table "pages_users", id: false, force: true do |t|
    t.integer "page_id"
    t.integer "user_id"
  end

  add_index "pages_users", ["page_id"], name: "index_pages_users_on_page_id", using: :btree
  add_index "pages_users", ["user_id"], name: "index_pages_users_on_user_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree

  create_table "subjects", force: true do |t|
    t.string "subject_code", default: ""
    t.string "subject_name", default: ""
  end

  create_table "tab_nodes", force: true do |t|
    t.integer "tab_id"
    t.integer "node_id"
    t.integer "position"
  end

  add_index "tab_nodes", ["node_id"], name: "index_tab_resources_on_resource_id", using: :btree
  add_index "tab_nodes", ["tab_id"], name: "index_tab_resources_on_tab_id", using: :btree

  create_table "tabs", force: true do |t|
    t.string   "tab_name"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "template",     default: 2
    t.integer  "tabable_id"
    t.string   "tabable_type"
  end

  add_index "tabs", ["tabable_id", "tabable_type"], name: "index_tabs_on_tabable_id_and_tabable_type", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  create_table "users", force: true do |t|
    t.string  "name",          default: "",       null: false
    t.string  "hashed_psswrd", default: "",       null: false
    t.string  "email",         default: "",       null: false
    t.string  "salt",          default: "",       null: false
    t.string  "role",          default: "author", null: false
    t.integer "node_id"
  end

end
