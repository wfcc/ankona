class AddBirthDateToAuthor < ActiveRecord::Migration
  def self.up
    add_column :authors, :birth_date, :timestamp
  end

  def self.down
    remove_column :authors, :birth_date
  end
end
