class LoadUsersData < ActiveRecord::Migration
  def self.up
    aUser = User.new({:user_id => 'pierre', :roles => 'admin'})
      aUser.password='pierre'
      aUser.save!
    aUser = User.new({:user_id => 'su', :roles => 'su'})
      aUser.password='su'
      aUser.save!
  end

  def self.down
    User.delete_all
  end
end
