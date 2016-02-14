class AddCotisationRabais < ActiveRecord::Migration
  def self.up
    add_column :cotisations, :rabais_preinscription, :decimal, {:precision => 8, :scale => 2, :default => 0}
  end

  def self.down
    drop_column :cotisations, :rabais_preinscription
  end
end
