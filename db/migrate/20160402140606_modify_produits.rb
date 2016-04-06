class ModifyProduits < ActiveRecord::Migration
  def change
    change_column :produits, :description_fr, :text
    change_column :produits, :description_en, :text
  end
end
