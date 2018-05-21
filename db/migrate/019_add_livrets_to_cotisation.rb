class AddLivretsToCotisation < ActiveRecord::Migration[5.0]
  def self.up
    add_column :cotisations, :nombre_billets, :integer, {:default => 0}
    add_column :cotisations, :cout_billets, :decimal, {:precision => 8, :scale => 2, :default => 0}
    add_column :constantes,  :cout_billet,  :decimal, {:precision => 8, :scale => 2, :default => 0.0}
  end

  def self.down
    drop_column :cotisations, :cout_billets, :nombre_billets
    drop_column :constantes,  :cout_billet
  end
end
