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

ActiveRecord::Schema.define(:version => 18) do

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.string   "original"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "birth_date"
  end

  create_table "authors_diagrams", :id => false, :force => true do |t|
    t.integer "author_id"
    t.integer "diagram_id"
  end

  create_table "collections", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.boolean "public"
  end

  create_table "collections_diagrams", :id => false, :force => true do |t|
    t.integer "diagram_id"
    t.integer "collection_id"
  end

  create_table "competitions", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "announce"
    t.boolean  "open"
    t.date     "deadline"
    t.boolean  "complete"
    t.text     "results"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "formal"
  end

  create_table "diagrams", :force => true do |t|
    t.string   "label"
    t.date     "published"
    t.string   "position"
    t.string   "stipulation"
    t.string   "twin"
    t.text     "solution"
    t.boolean  "tested"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "white"
    t.string   "black"
    t.text     "comment"
    t.string   "award"
    t.integer  "author_id"
    t.string   "source"
  end

  create_table "diagrams_collections", :id => false, :force => true do |t|
    t.integer "daigram_id"
    t.integer "collection_id"
  end

  create_table "diagrams_sections", :id => false, :force => true do |t|
    t.integer "diagram_id"
    t.integer "section_id"
  end

  create_table "faqs", :force => true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imports", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.string   "table"
    t.integer  "item"
    t.boolean  "accepted"
    t.string   "email"
  end

  create_table "posts", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sections", :force => true do |t|
    t.integer  "competition_id"
    t.integer  "user_id"
    t.string   "name"
    t.text     "theme"
    t.string   "pattern"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections_users", :id => false, :force => true do |t|
    t.integer "section_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "country"
    t.text     "address"
    t.text     "comment"
    t.string   "perishable_token",  :default => "", :null => false
  end

  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
