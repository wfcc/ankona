class CreateMarks < ActiveRecord::Migration
  def self.up
    create_table :marks do |t|
      t.references :diagram
      t.references :section
      t.float :nummark
      t.string :textmark
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    #drop_table :marks
  end
end
