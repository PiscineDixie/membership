class AddEcussonsRemisToCotisation < ActiveRecord::Migration[5.0]
  def change
    add_column :cotisations, :ecussons_remis, :boolean, default: false
  end
end
