class CreateMembres < ActiveRecord::Migration
  def self.up
    create_table :membres, :id => true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.references :famille
      t.string :nom,         :null => false
      t.string :prenom,      :null => false
      t.date   :naissance,   :null => false
      t.string :ecusson,     :null => false
      
      t.string :cours_de_natation, :default => ""
      t.string :session_de_natation, :default => ""

      t.timestamps
    end
    add_index :membres, [:famille_id], :unique => false, :name => 'par_famille'
  end

  def self.down
    remove_index :membres, :name => :par_famille
    drop_table :membres
  end
end
