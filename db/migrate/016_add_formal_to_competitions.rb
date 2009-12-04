class AddFormalToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :formal, :boolean
    create_table :diagrams_sections, :id => false do |t|
      t.references :diagram
      t.references :section
    end
  end

  def self.down
    remove_column :competitions, :formal
    drop_table :diagrams_sections
  end
end
