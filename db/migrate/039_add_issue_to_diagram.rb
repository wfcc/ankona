class AddIssueToDiagram < ActiveRecord::Migration
  def self.up
    add_column :diagrams, :issue, :string
  end

  def self.down
    remove_column :diagrams, :issue
  end
end
