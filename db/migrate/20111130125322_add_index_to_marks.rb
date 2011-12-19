class AddIndexToMarks < ActiveRecord::Migration
  def change
    add_index :marks, [:diagram_id, :section_id, :user_id], unique: true
  end
end
