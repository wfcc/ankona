class AddReferenceToDiagram < ActiveRecord::Migration
  def change
    add_column :diagrams, :reference, :string
  end
end
