class AddAdultFeeToConstantes < ActiveRecord::Migration[7.0]
  def change
    add_column :constantes, :adulte_additionel, :decimal, precision: 8, scale: 2, null: false, default: 25.0
  end
end
