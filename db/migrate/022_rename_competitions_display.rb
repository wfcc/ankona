class RenameCompetitionsDisplay < ActiveRecord::Migration
  def self.up
    rename_column :statuses, :display, :h_display
  end

  def self.down
  end
end
