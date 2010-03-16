class CreatePublications < ActiveRecord::Migration
  def self.up                                     
    create_table :publications do |t|
      t.string :name
      t.date :published
      t.sring :label
    end    
  end

  def self.down
    drop_table :publications
  end
end
