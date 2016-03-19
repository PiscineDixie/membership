class AddInteracToPaiements < ActiveRecord::Migration
  def change
    change_column :paiements, :comptant, :integer, default: 0
    rename_column :paiements, :comptant, :methode
  end
end
