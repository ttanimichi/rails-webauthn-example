class AddWebauthnUserHandleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :webauthn_user_handle, :string
    add_index :users, :webauthn_user_handle, unique: true
  end
end
