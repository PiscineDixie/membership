# coding: utf-8
require 'montant_cotisation'

#
# Contient la cotisation pour la famille
# Cette cotisation est calculee par la classe MontantCotisation avec les donnees familiale
# et les constantes.
# La cotisation est divisee en fraction taxable et non-taxable.
# En sus du montant de la cotisation, nous avons:
#  - rabais pour pre-inscription: Montant soustrait du total taxable
#  - exemption: Montant positif qui soustrait la cotisation. Permet d'offrir des cadeaux.
#

class Cotisation < ActiveRecord::Base

  belongs_to :famille, inverse_of: :cotisation
  
  # Calculer automatiquement le cout des billets d'apres leur nombre
  def initialize(parms)
    super
    if (parms && parms[:nombre_billets])
      self.cout_billets = Constantes.instance.cout_billet * parms[:nombre_billets].to_i
    end
  end
  
  def update(parms)
    if (parms && parms[:nombre_billets])
      self.cout_billets = Constantes.instance.cout_billet * parms[:nombre_billets].to_i
    end
    super
  end
  
  def billets
    self.cout_billets.nil? ? 0 : self.cout_billets
  end
  
  def ajustements
    exempt = self.cotisation_exemption.nil? ? 0 : self.cotisation_exemption;
    rabais = self.rabais_preinscription.nil? ? 0 : self.rabais_preinscription;
    suppl = self.frais_supplementaires.nil? ? 0 : self.frais_supplementaires;
    return suppl - exempt - rabais
  end

  def total
    return self.cotisation_calculee + ajustements + billets;
  end
  
  # Argument est une instance de la class Famille.
  # Retourne un hash avec les clef: montantBase, montantNatation, montantBronze, montantActivite
  # Pour chaque membre du hash, une array de [taxable non-taxable]
  def calcule
    mInd = MontantCotisation.new
    mFam = MontantCotisation.new
    mInd.asIndividu(self.famille)
    mFam.asFamille(self.famille)
    familiale = mFam.total < mInd.total
    mc =  familiale ? mFam : mInd
    self.cotisation_calculee = mc.total
    self.non_taxable = mc.totalNonTaxable
 
    # Si c'etait une cotisation familiale et maintenant individuel, on
    # enleve le rabais de pre-inscription
    self.rabais_preinscription = 0 if self.familiale && !familiale
    
    # Je ne reduit pas le rabais de pre-inscription si j'en ai deja un.
    self.rabais_preinscription = mc.rabaisPreInscription if self.rabais_preinscription < mc.rabaisPreInscription
    
    self.familiale = familiale

    # Sauver les details de la cotisation pour affichage. Pas utilise par la logique.
    desc = mc.description(self.famille.english?)
    self.frais1 = desc[0][1]
    self.frais1_explication = desc[0][0]
    self.frais2 = desc.size > 1 ? desc[1][1] : 0
    self.frais2_explication = desc.size > 1 ? desc[1][0] : ''
    self.frais3 = desc.size > 2 ? desc[2][1] : 0
    self.frais3_explication = desc.size > 2 ? desc[2][0] : ''
    self.frais4 = desc.size > 3 ? desc[3][1] : 0
    self.frais4_explication = desc.size > 3 ? desc[3][0] : ''
    self.frais5 = desc.size > 4 ? desc[4][1] : 0
    self.frais5_explication = desc.size > 4 ? desc[4][0] : ''
    self.frais6 =  desc.size > 5 ? desc[5][1] : 0
    self.frais6_explication = desc.size > 5 ? desc[5][0] : ''
    
    save!
  end
  
  # Stats overall
  def self.totalAnnuel
    res = 0
    t = Cotisation.sum(:cotisation_calculee)
    res += t unless t.nil? 
    t = Cotisation.sum(:cotisation_exemption)
    res -= t unless t.nil?
    t = Cotisation.sum(:rabais_preinscription)
    res -= t unless t.nil?
    t = Cotisation.sum(:cout_billets)
    res += t unless t.nil?
    t = Cotisation.sum(:frais_supplementaires)
    res += t unless t.nil?
    res
  end
  
end
