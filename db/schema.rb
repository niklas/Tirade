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

ActiveRecord::Schema.define(:version => 8) do

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
  end

  create_table "images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "parts", :force => true do |t|
    t.string   "name"
    t.string   "filename"
    t.text     "options"
    t.text     "preferred_types"
    t.integer  "subpart_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "renderings", :force => true do |t|
    t.integer  "page_id"
    t.integer  "content_id"
    t.integer  "part_id"
    t.integer  "grid_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password_hash", :limit => 40
    t.string   "password_salt", :limit => 40
    t.datetime "verified_at"
    t.string   "email"
    t.string   "remember_me",   :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
