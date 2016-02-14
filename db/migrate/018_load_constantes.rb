class LoadConstantes < ActiveRecord::Migration
  def self.up
    c = Constantes.new
    c.baseSenior = 50
    c.baseIndividu = 105
    c.baseFamille = 180
    c.activiteSenior = 20
    c.activiteIndividu = 40
    c.activiteFamille = 75
    c.rabaisPreInscriptionSenior = 0
    c.rabaisPreInscriptionIndividu = 10
    c.rabaisPreInscriptionFamille = 20
    c.finPreInscription = '2000-03-31'
    c.codeLeconNatation = 'LN'
    c.save!
  end

  def self.down
  end
end
