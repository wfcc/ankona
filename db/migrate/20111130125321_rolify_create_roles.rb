class RolifyCreateRoles < ActiveRecord::Migration
  def change
#    create_table(:roles) do |t|
#      t.string :name
#      t.references :resource, :polymorphic => true
#
#      t.timestamps
#    end

  # emulating polymorphic above
  add_column :roles, :resource_id, :integer
  add_column :roles, :resource_type, :string


#    create_table(:users_roles, :id => false) do |t|
#      t.references :user
#      t.references :role
#    end

    add_index(:roles, :name)
    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:roles_users, [ :user_id, :role_id ])
  end
end
