class AddSourceToDiagram < ActiveRecord::Migration
  def self.up
    add_column :diagrams, :source, :string
  end

  def self.down
    remove_column :diagrams, :source
  end
end
