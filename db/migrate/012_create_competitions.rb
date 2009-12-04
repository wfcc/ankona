class CreateCompetitions < ActiveRecord::Migration
  def self.up
    create_table :competitions do |t|
      t.references :user
      t.string :name
      t.text :announce
      t.boolean :open
      t.timestamp :deadline
      t.boolean :complete
      t.text :results

      t.timestamps
    end
  end

  def self.down
    drop_table :competitions
  end
end
