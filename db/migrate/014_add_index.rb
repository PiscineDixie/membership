class AddIndex < ActiveRecord::Migration[5.0]
  def self.up
    add_index :familles, [:code_acces], :unique => true, :name => 'par_code_acces'
  end

  def self.down
    remove_index :familles, :name => :par_code_acces
  end
end
