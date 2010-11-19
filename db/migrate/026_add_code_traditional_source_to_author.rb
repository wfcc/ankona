class AddCodeTraditionalSourceToAuthor < ActiveRecord::Migration
  def self.up
    add_column :authors, :code, :string
    add_column :authors, :traditional, :string
    add_column :authors, :source, :string
  end

  def self.down
    remove_column :authors, :source
    remove_column :authors, :traditional
    remove_column :authors, :code
  end
end
