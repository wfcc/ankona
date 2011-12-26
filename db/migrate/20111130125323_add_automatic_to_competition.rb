class AddAutomaticToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :automatic, :boolean
  end
end
