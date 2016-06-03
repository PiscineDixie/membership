class AddEcussonsRemisToCotisation < ActiveRecord::Migration
  def change
    add_column :cotisations, :ecussons_remis, :boolean, default: false
  end
end
