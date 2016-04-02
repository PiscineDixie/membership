class Panier
  
  class Item
    attr_accessor :produit, :quantite, :code, :montant
  end
  
  attr_reader :items   # array instances of Item
  
  def initialize
    @items = Array.new
  end
  
  def empty?
    return @items.empty?
  end
  
  # Montant total des marchandises a l'interieur du panier
  def total
    return @items.reduce(0) { |t, a | t + a.montant }
  end
  
  # AJouter un item dans le panier
  def addItem(produit, desc, qty)
    item = Item.new
    item.produit = produit.id
    item.quantite = qty;
    item.code = desc;
    item.montant = qty * produit.prix
    @items << item
  end
  
  # Retirer un item du panier
  def remItem(itemIdx)
    @items.delete_at(itemIdx)
  end
  
  # Sauver la commande
  # @return la Commande creee ou nil
  def save(famille)
    return nil if @items.empty?
    
    # Creer la commande
    return Commande.fromPanier(self, famille)
  end
  
  
end