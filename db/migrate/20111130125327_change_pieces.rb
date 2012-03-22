class ChangePieces < ActiveRecord::Migration
  def up
  	change_column :diagrams, :pieces, :text
  end

  def down
  end
end
