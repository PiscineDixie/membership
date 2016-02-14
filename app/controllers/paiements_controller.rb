# coding: utf-8
class PaiementsController < ApplicationController

  # Pour permettre d'acceder lorsque precede d'une famille dans le URL (REST)
  before_action :load_famille, :except => [:revenus, :depots]
  before_action :check_admin
  
  def load_famille
    @famille = Famille.find(params[:famille_id])
  end
  
  # GET /paiements/1
  # GET /paiements/1.xml
  def show
    @paiement = @famille.paiements.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @paiement }
    end
  end
  
  def edit
    @paiement = @famille.paiements.find(params[:id])
  end

  # GET /paiements/new
  # GET /paiements/new.xml
  def new
    @paiement = @famille.paiements.build
    @paiement.par = User.sessionUserId(session[:user])
    @paiement.montant = @famille.cotisationDue

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @paiement }
    end
  end


  # POST /paiements
  # POST /paiements.xml
  def create
    @paiement = @famille.paiements.new(paiement_params(params))

    if @paiement.montant == 0
      flash[:notice] = 'Le montant du paiement ne peut être zéro.'
      render :action => "new"
      return
    end
    
    @paiement.par = User.sessionUserId(session[:user])
    if @paiement.save
      flash[:notice] = 'Paiement enregistré.'
      
      # Expedier le courriel de confirmation si desire
      if params[:courriel] && !@famille.courriels.empty?
        FamilleMailer.paiement_notif(@famille, @paiement, @famille.courriels).deliver
      end
      redirect_to(famille_path(@famille))
    else
      render :action => "new"
    end
  end


  # DELETE /paiements/1
  # Le paiement n'est pas enleve mais nous enregistrons plutot un paiement negatif
  # du meme montant afin de corriger les rapports pour les taxes.
  def destroy
    @paiement = @famille.paiements.find(params[:id])
    @paiement2 = @famille.paiements.new({
      :date        => Date.today(),
      :montant     => @paiement.montant * -1,
      :non_taxable => @paiement.non_taxable * -1,
      :taxable     => @paiement.taxable * -1,
      :tps         => @paiement.tps * -1,
      :tvq         => @paiement.tvq * -1,
      :comptant    => @paiement.comptant,
      :no_cheque   => @paiement.no_cheque,
      :par         => User.sessionUserId(session[:user]),
      :note        => "Annulation du paiement du " + @paiement.date.to_s})

    @paiement2.save!
  
    flash[:notice] = 'Paiement annulé.'
    redirect_to(famille_path(@famille))
  end
  
  def update
    @paiement = @famille.paiements.find(params[:id])
    datePrecedente = @paiement.date
    if @paiement.update_attributes(paiement_params(params))
      FamilleMailer.edit_paiement(@famille, @paiement, datePrecedente).deliver
      flash[:notice] = "Paiement modifié"
      redirect_to(@famille)
    else
      render :action => "edit"
    end
  end
  
  # Les revenus pour l'interval donné
  # params[:debut] - date du début du rapport
  # params[:fin] - date de la find du rapport
  def revenus
    @debut = Date.new(params['debut']['year'].to_i, params['debut']['month'].to_i, params['debut']['day'].to_i)
    @fin   = Date.new(params['fin']['year'].to_i, params['fin']['month'].to_i, params['fin']['day'].to_i)
  end

  # Les dépots bancaire à préparer pour l'interval donné
  # params[:debut] - date du début du rapport
  # params[:fin] - date de la find du rapport
  def depots
    @debut = Date.new(params['debut']['year'].to_i, params['debut']['month'].to_i, params['debut']['day'].to_i)
    @fin   = Date.new(params['fin']['year'].to_i, params['fin']['month'].to_i, params['fin']['day'].to_i)
  end
  
  private
  
  def paiement_params(params)
    params.require(:paiement).permit([:date, :montant, :non_taxable, :taxable, :tps, :tvq, :comptant, :no_cheque, :par, :note])
  end
end
