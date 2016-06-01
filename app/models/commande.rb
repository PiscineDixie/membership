# coding: utf-8
class Commande < ActiveRecord::Base
  
  belongs_to :famille, inverse_of: :commandes;
  has_many :achats, inverse_of: :commande, dependent: :delete_all
  belongs_to  :paiement 
  
  enum etat: [:entree, :payee, :commandee, :livree]
    
  def due
    return self.entree? ? self.total : 0
  end
  
  # Enregistrer un paiement pour une commande
  def withPaiement(paiement)
    self.etat = :payee;
    self.paiement = paiement
    self.save!
  end
  
  # Le paiement d'une commande est annulee.
  def annulationPaiement()
    self.paiement = nil
    self.etat = :entree
    self.save!
  end
  
  # Le prochain etat logique de la commande
  def prochainEtat
    Commande.etats.key(Commande.etats[self.etat] + 1)
  end
  
  # Creer une commande a partir d'un panier
  # @return instance creee
  def self.fromPanier(panier, famille)
    commande = Commande.new
    commande.famille = famille
    commande.etat = :entree
    commande.total = 0
    commande.save!
    
    # Creer tous les items achetes
    panier.items.each do | item |
      achat = Achat.new
      achat.produit_id = item.produit
      achat.commande = commande
      achat.code = item.code
      achat.quantite = item.quantite
      achat.montant = item.montant
      commande.total = commande.total + achat.montant
      achat.save!(achat)
    end
    
    commande.save!
    return commande
  end
  
  # Retourner la liste des paiements dans l'interval
  # @param debut Date
  # @param fin Date
  # @param [Commande.etats]
  def self.commandes(debut, fin, statuses)
    return Commande.
      where("created_at >= :minDate and created_at < :endDate and etat in (:statuses)", {
        minDate: debut.at_beginning_of_day.utc.strftime("%F %T"),
        endDate: fin.at_end_of_day.utc.strftime("%F %T"),
        statuses: statuses}).
      order(:id)
  end
  
  # Retourner le total des ventes pour la periode donnee.
  def self.total(debut, fin)
    return Commande.commandes(debut, fin).sum(:total)
  end
end