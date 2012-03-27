class AddPublicToDiagram < ActiveRecord::Migration
  def change
    add_column :diagrams, :public, :boolean

  end
end
