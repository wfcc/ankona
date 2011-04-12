class AddUserToMarks < ActiveRecord::Migration
  def self.up
    change_table :marks do |t|
      t.references :user
    end
  end

  def self.down
    remove_column :marks, :user
  end
end
