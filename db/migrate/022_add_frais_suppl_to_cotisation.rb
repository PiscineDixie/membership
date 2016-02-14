class AddFraisSupplToCotisation < ActiveRecord::Migration
  def self.up
    add_column :cotisations,  :frais_supplementaires, :decimal, {:precision => 8, :scale => 2, :default => 0}
  end

  def self.down
    remove_column :cotisations, :frais_supplementaires
  end
end
