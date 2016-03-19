# coding: utf-8
class Paiement < ActiveRecord::Base

  enum methode: [ :cheque, :comptant, :interac ]

  validates_presence_of :montant, :date
  validates_numericality_of :montant

  # Les taux de taxes en vigueur
  @@tauxDeTPS = 0.05   # La TPS est de 5.00%
  @@tauxDeTVQ = 0.09975 # La TVQ est de 9.975%
  @@tauxAvantTaxes = 1 + (@@tauxDeTPS + @@tauxDeTVQ)
  
  belongs_to :famille, inverse_of: :paiements

  before_save :calculDesTaxes
  
  # Cette method est invoque pour calcule automatiquement le montant
  # de taxes payables. Dans ce systeme:
  #  - le client paie un montant total. De ce total une partie est taxable
  #    et une partie non taxable. L'organisation doit donc les taxes sur
  #    la partie taxable.
  # Utilise Cotisation.non_taxable, cotisation.total
  # Il se peut que plusieurs paiements soient enregistres pour payer la
  # cotisation total.
  # Les premiers montants sont appliques contre la partie non-taxable
  # de la contribution. Donc pas de taxes. Lorsque ce montant est entierement
  # paye, alors les taxes s'appliquent sur le reste. 
  def calculDesTaxes
    # Si un montant negatif, il s'agit d'une correction pour un
    # paiement annule. Ne rien modifier.
    return if self.montant < 0
      
    # Trouver la somme des montants non-taxable de tous les paiements precedents
    if self.new_record? # Est-ce un nouveau paiement ou une modification?
      paiementsNonTaxable = self.famille.paiements.sum(:non_taxable)
    else
      paiementsNonTaxable = self.famille.paiements.sum(:non_taxable) - Paiement.find(self.id).non_taxable
    end
    paiementsNonTaxable = 0 if paiementsNonTaxable.nil?
    
    if (paiementsNonTaxable < self.famille.cotisation.non_taxable)
      self.non_taxable = self.famille.cotisation.non_taxable - paiementsNonTaxable
      self.non_taxable = self.montant if self.non_taxable > self.montant
    end
    
    brut = self.montant - self.non_taxable;
    if brut > 0
      net = (brut / @@tauxAvantTaxes * 100).round / 100.0
      self.tps = (net * @@tauxDeTPS *100).round / 100.0
      self.tvq = (net * @@tauxDeTVQ * 100).round / 100.0
      self.taxable = brut - self.tps - self.tvq
    else
      self.tps = 0
      self.tvq = 0
      self.taxable = 0
    end   
  end
  
  def self.sumRange(debut, fin, colonne)
    Paiement.
      where("date >= :minDate and date <= :endDate", 
        {:minDate => debut.to_s(:db), :endDate => fin.to_s(:db)}).
      sum(colonne)
  end

  def self.sumMontantMethode(debut, fin, methode)
    Paiement.
      where("date >= :minDate and date <= :endDate and methode = :methode", 
        {minDate: debut.to_s(:db), endDate: fin.to_s(:db), methode: Paiement.methodes[methode]}).
      sum(:montant)
  end
  
  def self.sumMontantCheque(debut, fin)
    sumMontantMethode(debut, fin, :cheque)
  end

  def self.sumMontantComptant(debut, fin)
    sumMontantMethode(debut, fin, :comptant)
  end

  def self.sumMontantInterac(debut, fin)
    sumMontantMethode(debut, fin, :interac)
  end
  
  def self.totalAnnuel
    Paiement.sum(:montant)
  end
  
  def self.paiements(debut, fin)
    return Paiement.
      where("date >= :minDate and date <= :endDate", 
        {:minDate => debut.to_s(:db), :endDate => fin.to_s(:db)}).
      order(:created_at)
  end
end
