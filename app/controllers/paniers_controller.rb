class PaniersController < ApplicationController

  layout "public"
  
  before_action :create_panier
  around_action :set_locale
  
  def create_panier
    @panier = session[:panier];
    if @panier.nil?
      @panier = session[:panier] = Panier.new
    end
    @famille = Famille.find_by_id(session[:familleId])
  end
  
  def set_locale(&action)
    I18n.with_locale(@famille.english? ? :en : :fr, &action)
  end

  def show
    @produits = Produit.all
  end
  
  def _show(panier)
    @produits = Produit.all
    render action: 'show'
  end
  
  # Aller au checkout pour confirmer la commande
  def checkout
    if (params[:cancel])
      session.delete(:panier)
      redirect_to public_home_path
      return;
    end

    # Render 'checkout'
  end
  
  # Confirmation de l'achat
  def acheter  
    if (params[:cancel])
      session.delete(:panier)
      redirect_to public_home_path
      return;
    end
    
    if (params[:retour])
      redirect_to paniers_show_path(1)
      return;
    end
    
    if (params[:rem])
      @panier.remItem(params[:rem][0].to_i)
      render action: 'checkout'
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
      render action: 'checkout'
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