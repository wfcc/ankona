class AddDisplayToStatus < ActiveRecord::Migration
  def self.up
    add_column :statuses, :display, :string
  end

  def self.down
    remove_column :statuses, :display
  end
end
