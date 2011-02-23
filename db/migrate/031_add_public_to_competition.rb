class AddPublicToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :private, :boolean
  end

  def self.down
  end
end
