# coding: utf-8
class ProduitsController < ApplicationController
  
  before_action :check_admin
  
  # GET /produits
  def index
    @produits = Produit.all
  end

  # GET /produits/1
  def show
    @produit = Produit.find(params[:id])
  end

  # GET /produits/new
  def new
    @produit = Produit.new
  end

  # GET /produits/1/edit
  def edit
    @produit = Produit.find(params[:id])
  end

  # POST /produits
  def create
    if (params[:cancel])
      redirect_to(produits_url)
      return;
    end
    
    @produit = Produit.new(produit_params(params))
  
    if @produit.save
      flash[:notice] = 'Nouveau produit créé.'
      redirect_to(@produit)
      return
    end
     
    # Les parametres etaient invalides, on recommence
    render :action => "new"
  end

  # PUT /produits/1
  def update
    @produit = Produit.find(params[:id])

    if (params[:cancel])
      redirect_to(@produit)
      return;
    end
    
    if @produit.update(produit_params(params))
      flash[:notice] = 'Produit modifié.'
      redirect_to(@produit)
    else
      render :action => "edit"
    end
  end

  # DELETE /produits/1
  def destroy
    @produit = Produit.find(params[:id])
    @produit.destroy
    redirect_to(produits_url)
  end
  
  def produit_params(params)
    params.require(:produit).permit([:titre_fr, :titre_en, :description_fr, :description_en, :prix, :tailles_fr, :images])
  end
end
