class StartOver < ActiveRecord::Migration
  def self.up

  create_table "collections", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.boolean "public"
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
  end

  create_table "collections_diagrams", :id => false, :force => true do |t|
    t.integer "collection_id"
    t.integer "diagram_id"
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
  end

  def self.down
  end
end
