#
# Represente un paiement envers la cotisation annuelle et des activites
#
class CreateCotisations < ActiveRecord::Migration
  def self.up
    create_table :cotisations, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.references :famille
      
      t.decimal :cotisation_calculee,  :precision => 8, :scale => 2, :default => 0
      t.decimal :cotisation_exemption, :precision => 8, :scale => 2, :default => 0
      t.decimal :non_taxable,  :precision => 8, :scale => 2, :default => 0
      t.boolean :familiale

      # Des "lignes" d'explication pour ce qui a ete calcule comme cotisation
      t.decimal :frais1,  :precision => 8, :scale => 2, :default => 0
      t.string  :frais1_explication, :default => ''
      
      t.decimal :frais2,  :precision => 8, :scale => 2, :default => 0
      t.string  :frais2_explication, :default => ''
      
      t.decimal :frais3,  :precision => 8, :scale => 2, :default => 0
      t.string  :frais3_explication, :default => ''
      
      t.decimal :frais4,  :precision => 8, :scale => 2, :default => 0
      t.string  :frais4_explication, :default => ''

      t.decimal :frais5,  :precision => 8, :scale => 2, :default => 0
      t.string  :frais5_explication, :default => ''

      t.decimal :frais6,  :precision => 8, :scale => 2, :default => 0
      t.string  :frais6_explication, :default => ''


      t.timestamps
    end
    add_index :cotisations, [:famille_id], :unique => true, :name => 'par_famille'
  end

  def self.down
    remove_index :cotisations, :name => :par_famille
    drop_table :cotisations
  end
end
