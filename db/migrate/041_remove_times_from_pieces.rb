class RemoveTimesFromPieces < ActiveRecord::Migration
  def up
    remove_column :pieces, :created_at
    remove_column :pieces, :updated_at
  end

  def down
  end
end
