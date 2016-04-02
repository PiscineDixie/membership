# coding: utf-8
class Achat < ActiveRecord::Base
  
  validates_numericality_of :montant, :quantite
  
  belongs_to :commande, inverse_of: :achats
  belongs_to :produit
  
  # 
  # Retourne le total de chaque produit vendus durant la periode donnee
  # On obtient un objet Achat pour chaque distinct produit+code. La quantite
  # est le total vendue durant la periode.
  # @param debut Date
  # @param fin Date
  # @param [Commande.etats]
  def self.achats(debut, fin, statuses)
    Achat.
      joins(:commande).
      where("achats.created_at >= :minDate and achats.created_at < :endDate and commandes.etat in (:statuses)", {
         minDate: debut.at_beginning_of_day.utc.strftime("%F %T"),
         endDate: fin.at_end_of_day.utc.strftime("%F %T"),
         statuses: statuses}).
      select("produit_id,code,sum(quantite) as quantite").
      group('produit_id', :code)
  end

end