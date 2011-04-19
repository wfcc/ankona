class AddTypeToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :ttype, :integer
  end

  def self.down
    remove_column :competitions, :ttype
  end
end
