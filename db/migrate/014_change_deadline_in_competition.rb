class ChangeDeadlineInCompetition < ActiveRecord::Migration
  def self.up
    change_column :competitions, :deadline, :date
  end

  def self.down
  end
end
