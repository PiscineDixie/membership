class CreateProducts < ActiveRecord::Migration
  def change
    create_table :produits do |t|
      t.string :titre_fr
      t.string :titre_en
      t.string :description_fr
      t.string :description_en
      t.string :tailles_fr
      t.string :images
      t.decimal :prix,  :precision => 8, :scale => 2
      t.timestamps
    end
  end
end
