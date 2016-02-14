class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.string :user_id
      t.string :password_salt
      t.string :password_hash
      t.string :roles

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
