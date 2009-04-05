# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090405184410) do

  create_table "artists", :force => true do |t|
    t.string   "title"
    t.string   "home_page_url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "myspace_url"
    t.string   "slug"
  end

  create_table "concerts", :force => true do |t|
    t.string   "title"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "headliner_id"
    t.datetime "doors_open_at"
    t.float    "advance_sale_price"
    t.float    "box_office_price"
    t.integer  "location_id"
    t.string   "slug"
  end

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
    t.string   "slug",         :default => ""
  end

  create_table "gigs", :force => true do |t|
    t.integer  "position"
    t.integer  "artist_id"
    t.integer  "concert_id"
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
    t.boolean  "inherit_renderings", :default => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_roles", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "role_id"
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "locations", :force => true do |t|
    t.string   "title"
    t.string   "street"
    t.string   "street_number"
    t.integer  "zipcode"
    t.string   "town"
    t.string   "state"
    t.string   "url"
    t.string   "type"
    t.text     "opening_times"
    t.text     "description"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "machinetaggings", :force => true do |t|
    t.integer  "machinetag_id"
    t.integer  "machinetaggable_id"
    t.string   "machinetaggable_type", :limit => 32
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "machinetaggings", ["machinetag_id", "machinetaggable_type"], :name => "index_mtaggings_on_mtag_id_and_mtaggable_type"
  add_index "machinetaggings", ["machinetaggable_id", "machinetaggable_type"], :name => "index_mtaggings_on_mtaggable_id_and_mtaggable_type"
  add_index "machinetaggings", ["machinetag_id", "machinetaggable_type", "user_id"], :name => "index_mtaggings_on_user_id_and_mtag_id_and_mtaggable_type"
  add_index "machinetaggings", ["machinetaggable_id", "machinetaggable_type", "user_id"], :name => "index_mtaggings_on_user_id_and_mtaggable_id_and_mtaggable_type"

  create_table "machinetags", :force => true do |t|
    t.string   "namespace",             :limit => 128
    t.string   "key",                   :limit => 128
    t.string   "value",                 :limit => 1024
    t.integer  "machinetaggings_count",                 :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "machinetags", ["key"], :name => "index_mtags_on_key"
  add_index "machinetags", ["machinetaggings_count"], :name => "index_mtags_on_mtaggings_count"
  add_index "machinetags", ["namespace"], :name => "index_mtags_on_namespace"
  add_index "machinetags", ["value"], :name => "index_mtags_on_value"

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

  create_table "permissions", :force => true do |t|
    t.string   "app_controller"
    t.string   "app_method"
    t.boolean  "processed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "permission_id"
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

  create_table "plugin_schema_migrations", :id => false, :force => true do |t|
    t.string "plugin_name"
    t.string "version"
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
    t.string   "assignment",   :limit => 32, :default => "fixed"
    t.text     "scope"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.boolean  "is_public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.string   "var",        :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
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
    t.boolean  "is_admin"
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
