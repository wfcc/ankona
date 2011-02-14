class AddTestedToDiagram < ActiveRecord::Migration
  def self.up                 
    remove_column :diagrams, :tested
    add_column :diagrams, :tested, :integer
  end

  def self.down
  end
end
