class AddCourrielToUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :password_salt, :string
    remove_column :users, :password_hash, :string
    remove_column :users, :user_id, :string
    add_column :users, :courriel, :string
    add_column :users, :nom, :string
  end
end
