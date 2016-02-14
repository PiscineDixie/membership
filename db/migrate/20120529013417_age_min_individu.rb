#
# Migration pour ajouter une nouvelle constantes pour l'age minimum d'un
# membre individuel
#
class AgeMinIndividu < ActiveRecord::Migration
  def self.up
    add_column :constantes, :age_min_individu, :integer
  end

  def self.down
    drop_column :constantes, :age_min_individu
  end
end
