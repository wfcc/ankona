class AddPopeyeToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :popeye, :string

  end
end
