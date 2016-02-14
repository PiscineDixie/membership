# coding: utf-8
class CotisationsController < ApplicationController

  before_action :check_admin, :only => [:edit, :update, :destroy]
  before_action :authenticate, :except => [:edit, :update, :destroy]
  
  
  # Pour permettre d'acceder lorsque precede d'une famille dans le URL (REST)
  before_action :load_famille
  
  def load_famille
    @famille = Famille.find(params[:famille_id])
  end
  
  # GET /familles/:famille_id/cotisations/1
  def show
    @cotisation = @famille.cotisation
  end

  # Creer une cotisation veut dire faire son calcul
  # GET /familles/:famille_id//cotisations/new
  def new
    @famille.calculeCotisation
    redirect_to(famille_path(@famille))
  end

  # GET /familles/:famille_id//cotisations/1/edit
  def edit
    @cotisation = @famille.cotisation
  end

  # PUT /familles/:famille_id//cotisations/1
  def update
    @cotisation = @famille.cotisation

    if @cotisation.update(cotisation_params(params))
      flash[:notice] = 'Cotisation mise à jour.'
      redirect_to(famille_path(@famille))
    else
      render :action => "edit"
    end
  end

  # DELETE /familles/:famille_id//cotisations/1
  def destroy
    @famille.cotisation.destroy
    redirect_to(famille_path(@famille))
  end
  
  def cotisation_params(parms)
    params.require(:cotisation).permit([:nombre_billets, :cotisation_exemption, :rabais_preinscription, :frais_supplementaires])
  end
end
