class AddOrthodoxToPieces < ActiveRecord::Migration
  def change
  	Piece.reset_column_information
    add_column :pieces, :orthodox, :boolean unless Piece.column_names.include? 'orthodox'

  end
end
