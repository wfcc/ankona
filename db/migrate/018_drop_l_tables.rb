class DropLTables < ActiveRecord::Migration
  def self.up
    drop_table :l_diagrams
    drop_table :l_posts
    drop_table :l_users
    drop_table :l_collections
    drop_table :l_diagrams_collections
  end

  def self.down
  end
end
