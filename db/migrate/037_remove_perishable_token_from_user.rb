class RemovePerishableTokenFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :perishable_token
  end

  def self.down
  end
end
