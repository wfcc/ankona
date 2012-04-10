class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.references :diagram
      t.string :fef
      t.string :description

      t.timestamps
    end
    add_index :versions, :diagram_id
  end
end
