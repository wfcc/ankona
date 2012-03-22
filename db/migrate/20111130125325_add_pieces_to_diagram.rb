class AddPiecesToDiagram < ActiveRecord::Migration
  def change
    add_column :diagrams, :pieces, :string

  end
end
