class CreateFamilles < ActiveRecord::Migration
  def self.up
    create_table :familles, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.string :adresse1
      t.string :adresse2
      t.string :ville
      t.string :province,    :limit => 2
      t.string :code_postal, :limit => 6
      t.string :tel_soir,    :limit => 20
      t.string :tel_jour,    :limit => 20
      t.string :courriel1
      t.string :courriel2
      t.string :langue
      
      t.string :etat
      t.string :code_acces, :default => ''

      t.timestamps
    end
  end

  def self.down
    drop_table :familles
  end
end
