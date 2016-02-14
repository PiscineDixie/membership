class CreateConstantes < ActiveRecord::Migration
  def self.up
    create_table :constantes do |t|
      t.decimal :baseSenior,                     :precision => 8, :scale => 2, :default => 0.0
      t.decimal :baseIndividu,                   :precision => 8, :scale => 2, :default => 0.0
      t.decimal :baseFamille,                    :precision => 8, :scale => 2, :default => 0.0
      t.decimal :activiteSenior,                 :precision => 8, :scale => 2, :default => 0.0
      t.decimal :activiteIndividu,               :precision => 8, :scale => 2, :default => 0.0
      t.decimal :activiteFamille,                :precision => 8, :scale => 2, :default => 0.0
      t.decimal :rabaisPreInscriptionSenior,     :precision => 8, :scale => 2, :default => 0.0
      t.decimal :rabaisPreInscriptionIndividu,   :precision => 8, :scale => 2, :default => 0.0
      t.decimal :rabaisPreInscriptionFamille,    :precision => 8, :scale => 2, :default => 0.0
      t.date :finPreInscription
      t.string :codeLeconNatation

      t.timestamps
    end
  end

  def self.down
    drop_table :constantes
  end
end
