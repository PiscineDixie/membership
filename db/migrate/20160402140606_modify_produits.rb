class ModifyProduits < ActiveRecord::Migration[5.0]
  def change
    change_column :produits, :description_fr, :text
    change_column :produits, :description_en, :text
  end
end
