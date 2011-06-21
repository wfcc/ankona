class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string :name
      t.string :original

      t.timestamps
    end
    create_table :authors_diagrams, :id => false do |t|
      t.references :author
      t.references :diagram

    end
  end

  def self.down
    drop_table :authors
    drop_table :authors_diagrams
  end
end
