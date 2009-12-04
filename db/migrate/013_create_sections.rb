class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.references :competition
      t.references :user
      t.string :name
      t.text :theme
      t.string :pattern

      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
