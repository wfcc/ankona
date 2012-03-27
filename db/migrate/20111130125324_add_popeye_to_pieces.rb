class AddPopeyeToPieces < ActiveRecord::Migration
  def change
  	Piece.reset_column_information
    add_column :pieces, :popeye, :string unless Piece.column_names.include? 'popeye'

  end
end
