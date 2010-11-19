class AddSplitCodeToAuthor < ActiveRecord::Migration
  def self.up
    add_column :authors, :code_i, :integer
    add_column :authors, :code_a, :string
  end

  def self.down
    remove_column :authors, :code_a
    remove_column :authors, :code_i
  end
end
