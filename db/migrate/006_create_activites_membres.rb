#
# Creer la table pour la relation "has_and_belongs_to_many"
# entre une activite et un membre
# Ces tables n'ont pas de colonne "id"
#

class CreateActivitesMembres < ActiveRecord::Migration
  def self.up
    create_table :activites_membres, :id => false, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|

      t.references :activite
      t.references :membre
    end
    add_index :activites_membres, [:membre_id], :unique => false, :name => 'par_membre'
    add_index :activites_membres, [:activite_id], :unique => false, :name => 'par_activite'
  end

  def self.down
    remove_index :activites_membres, :name => :par_membre
    remove_index :activites_membres, :name => :par_activite
    drop_table :activites_membres
  end
end
