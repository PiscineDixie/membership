class PaniersController < ApplicationController

  layout "public"
  
  before_action :create_panier
  
  def create_panier
    @panier = session[:panier];
    if @panier.nil?
      @panier = session[:panier] = Panier.new
    end
    @famille = Famille.find_by_id(session[:familleId])
    I18n.locale= @famille.english?  ? :en : :fr
    
  end
  
  def show
    @produits = Produit.all
  end
  
  def _show(panier)
    @produits = Produit.all
    render action: 'show'
  end
  
  # Submit d'un panier lors pour l'achat de son contenu
  def create
    if (params[:cancel])
      session.delete(:panier)
      redirect_to public_home_path
      return;
    end

    if (params[:rem])
      @panier.remItem(params[:rem][0].to_i)
      redirect_to paniers_show_path(1)
      return
    end
    
    if @famille.nil?
      flash[:notice] = 'Famille non identifiée'
      redirect_to public_home_path
      return
    end
    
    @commande = @panier.save(@famille)
    unless @commande.nil?
      render action: 'created'
      session.delete(:panier)
    else
      redirect_to paniers_show_path(1)
    end
  end
  
  # Ajouter un item au panier
  # Ceci recoit une form avec les champs produit_id, quantite, desc
  def add_item
    produit = Produit.find(params[:produit_id])
    @panier.addItem(produit, params[:desc], params[:quantite].to_i)  
    redirect_to paniers_show_path(1)
  end
  
  # Annuler une commande
  def cancel
    @commande = Commande.find(params[:id])
    @commande.destroy
    flash[:notice] = t(:panier_cancel)
    redirect_to public_home_path
  end
  
  private
end