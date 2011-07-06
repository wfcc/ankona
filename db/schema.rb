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

ActiveRecord::Schema.define(:version => 39) do

  create_table "aaa", :id => false, :force => true do |t|
    t.integer "i",                :null => false
    t.string  "c",   :limit => 1, :null => false
    t.date    "d",                :null => false
    t.integer "pay"
  end

  create_table "aaaa", :id => false, :force => true do |t|
    t.integer "i",                :null => false
    t.string  "c",   :limit => 1, :null => false
    t.date    "d_d",              :null => false
    t.integer "pay"
  end

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.string   "original"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "birth_date"
    t.string   "code"
    t.string   "traditional"
    t.string   "source"
    t.integer  "code_i"
    t.string   "code_a"
  end

  create_table "authors_diagrams", :id => false, :force => true do |t|
    t.integer "author_id"
    t.integer "diagram_id"
  end

  create_table "bubu", :id => false, :force => true do |t|
    t.decimal "id", :precision => 10, :scale => 0
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
    t.integer  "status"
    t.boolean  "private"
    t.integer  "ttype"
  end

  create_table "diagrams", :force => true do |t|
    t.string   "label"
    t.date     "published"
    t.string   "position"
    t.string   "stipulation"
    t.string   "twin"
    t.text     "solution"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "white"
    t.string   "black"
    t.text     "comment"
    t.string   "award"
    t.integer  "author_id"
    t.string   "source"
    t.string   "fairy"
    t.integer  "tested"
    t.string   "issue"
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
    t.string   "role"
  end

  create_table "marks", :force => true do |t|
    t.integer  "diagram_id"
    t.integer  "section_id"
    t.float    "nummark"
    t.string   "textmark"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "posts", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publications", :force => true do |t|
    t.string  "name"
    t.date    "published"
    t.integer "diagram_id"
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

  create_table "statuses", :force => true do |t|
    t.string  "table"
    t.string  "name"
    t.integer "value"
    t.string  "h_display"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password"
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
    t.integer  "author_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
