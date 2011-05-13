class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.rename :login, :email
      t.rename :crypted_password, :encrypted_password
      t.recoverable
      t.rememberable
      t.trackable
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end

  def self.down
  end
end
