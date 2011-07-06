class AddRoleToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :role, :string
  end

  def self.down
    remove_column :invites, :role
  end
end
