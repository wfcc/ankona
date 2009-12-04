class AddCodeTableItemAcceptedToInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.timestamps
    end
    add_column :invites, :code, :string
    add_column :invites, :table, :string
    add_column :invites, :item, :integer
    add_column :invites, :accepted, :boolean
    add_column :invites, :email, :string

    create_table :sections_users, :id => false do |t|
      t.references :section
      t.references :user
    end
  end

  def self.down
    drop_table :invites
    drop_table :sections_users
  end
end
