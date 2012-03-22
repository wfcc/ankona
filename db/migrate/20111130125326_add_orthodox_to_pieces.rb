class AddOrthodoxToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :orthodox, :boolean

  end
end
