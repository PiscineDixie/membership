class CreateAchats < ActiveRecord::Migration[5.0]
  def change
    
    add_column :constantes, :tps, :decimal, precision: 8, scale: 6, default: 0.05
    add_column :constantes, :tvq, :decimal, precision: 8, scale: 6, default: 0.09975
    add_column :constantes, :finCommandes, :date
    
    create_table :commandes do |t|
      t.references :famille
      t.references :paiement
      t.integer :etat
      t.decimal :total,  :precision => 8, :scale => 2
      t.timestamps
    end
    
    create_table :achats do |t|
      t.references :commande
      t.references :produit
      t.string :code
      t.integer :quantite
      t.decimal :montant,  :precision => 8, :scale => 2
      t.timestamps
    end
  end
end
