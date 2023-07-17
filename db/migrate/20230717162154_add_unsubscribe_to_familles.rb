class AddUnsubscribeToFamilles < ActiveRecord::Migration[7.0]
  def change
    add_column :familles, :courriel_desabonne, :boolean, null: false, default: false
  end
end
