class IndexAuthorsDiagrams < ActiveRecord::Migration
  def self.up
    add_index :authors_diagrams, :author_id
    add_index :authors_diagrams, :diagram_id
  end

  def self.down
  end
end
