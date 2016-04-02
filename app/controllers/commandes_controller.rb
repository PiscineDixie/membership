# coding: utf-8

class CommandesController < ApplicationController

  before_action :authenticate

  def index
    @debut = Date.parse(params['debut'] || Date.new(1900,1,1).to_s)
    @fin   = Date.parse(params['fin'] || Date.today.to_s)
  end
  
  def show
    @commande = Commande.find(params[:id])
  end
  
  def edit
    @commande = Commande.find(params[:id])
  end
  
  def update
    @commande = Commande.find(params[:id])
      
    if (params[:cancel])
      redirect_to(@commande)
      return;
    end
    
    if @commande.update(commande_params(params))
      flash[:notice] = 'Commande modifiée.'
      redirect_to(@commande)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    commande = Commande.find(params[:id])
    commande.destroy
    redirect_to(commandes_path)
  end
  
  def commande_params(params)
    params.require(:commande).permit!
  end

end