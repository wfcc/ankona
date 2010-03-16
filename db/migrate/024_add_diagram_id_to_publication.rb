class AddDiagramIdToPublication < ActiveRecord::Migration
  def self.up
    add_column :publications, :diagram_id, :integer
  end

  def self.down
  end
end
