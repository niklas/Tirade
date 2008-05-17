# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 21) do

  create_table "contents", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "body"
    t.string   "type"
    t.string   "state"
    t.integer  "owner_id"
    t.datetime "published_at"
    t.integer  "position"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grids", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "yui"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "layout_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "yui",        :limit => 10
  end

  create_table "parts", :force => true do |t|
    t.string   "name"
    t.string   "filename"
    t.text     "options"
    t.text     "preferred_types"
    t.integer  "subpart_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "defined_options"
  end

  create_table "picturizations", :force => true do |t|
    t.integer  "image_id"
    t.integer  "pictureable_id"
    t.string   "pictureable_type"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plugin_schema_info", :id => false, :force => true do |t|
    t.string  "plugin_name"
    t.integer "version"
  end

  create_table "renderings", :force => true do |t|
    t.integer  "page_id"
    t.integer  "content_id"
    t.integer  "part_id"
    t.integer  "grid_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
    t.text     "options"
  end

  create_table "settings", :force => true do |t|
    t.string   "var",        :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "remember_token"
    t.string   "crypted_password",          :limit => 40
    t.string   "password_reset_code",       :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "activation_code",           :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.integer  "artist_id"
    t.string   "artist_name"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

end
