class CreatePaiements < ActiveRecord::Migration[5.0]
  def self.up
    create_table :paiements, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.references :famille
      t.date :date
      t.decimal :montant,      :precision => 8, :scale => 2, :default => 0
      t.decimal :non_taxable,  :precision => 8, :scale => 2, :default => 0
      t.decimal :taxable,      :precision => 8, :scale => 2, :default => 0
      t.decimal :tps,          :precision => 8, :scale => 2, :default => 0
      t.decimal :tvq,          :precision => 8, :scale => 2, :default => 0
      t.string  :note

      t.timestamps
    end
    add_index :paiements, [:famille_id], :unique => false, :name => 'par_famille'
  end

  def self.down
    remove_index :paiements, :name => :par_famille
    drop_table :paiements
  end
end
