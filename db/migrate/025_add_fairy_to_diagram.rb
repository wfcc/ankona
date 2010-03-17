class AddFairyToDiagram < ActiveRecord::Migration
  def self.up
    add_column :diagrams, :fairy, :string
  end

  def self.down
    remove_column :diagrams, :fairy
  end
end
