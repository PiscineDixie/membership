class CreateRecus < ActiveRecord::Migration
  def self.up
    create_table :recus, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.references :famille
      t.integer :annee
      t.string :info
      t.string :prenom
      t.string :nom
      t.date   :naissance,   :null => false
      t.decimal :montant,      :precision => 8, :scale => 2, :default => 0
      t.date   :montant_recu
    end
    add_index :recus, [:famille_id, :annee], :unique => false, :name => 'par_famille_annee'
  end

  def self.down
    remove_index :recus, :name => :par_famille_annee
    drop_table :recus
  end
end
