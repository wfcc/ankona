class AddStatusToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :status, :integer
  end

  def self.down
    remove_column :competitions, :status
  end
end
