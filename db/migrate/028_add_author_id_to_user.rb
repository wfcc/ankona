class AddAuthorIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :author_id, :integer
  end

  def self.down
    remove_column :users, :author_id
  end
end
