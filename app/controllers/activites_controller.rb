# coding: utf-8
class ActivitesController < ApplicationController
  before_action :check_su, :only => :update
  before_action :authenticate, :except => :update
  

  # GET /activites
  # GET /activites.xml
  def index
    @activites = Activite.all().order(:code)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activites }
    end
  end

  # GET /activites/1
  # GET /activites/1.xml
  def show
    @activite = Activite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activite }
    end
  end

  # GET /activites/new
  # GET /activites/new.xml
  def new
    @activite = Activite.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activite }
    end
  end

  # GET /activites/1/edit
  def edit
    @activite = Activite.find(params[:id])
  end

  # POST /activites
  # POST /activites.xml
  def create
    if (params[:cancel])
      redirect_to(activites_url)
      return;
    end
    
    @activite = Activite.new(activite_params(params))

    respond_to do |format|
      if @activite.save
        flash[:notice] = 'Activite was successfully created.'
        format.html { redirect_to(@activite) }
        format.xml  { render :xml => @activite, :status => :created, :location => @activite }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activite.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /activites/1
  # PUT /activites/1.xml
  def update
    @activite = Activite.find(params[:id])

    if (params[:cancel])
      redirect_to(@activite)
      return;
    end
    
    respond_to do |format|
      if @activite.update_attributes(activite_params(params))
        flash[:notice] = 'Activite was successfully updated.'
        format.html { redirect_to(@activite) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activite.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activites/1
  # DELETE /activites/1.xml
  def destroy
    @activite = Activite.find(params[:id])
    @activite.destroy

    respond_to do |format|
      format.html { redirect_to(activites_url) }
      format.xml  { head :ok }
    end
  end
  
  # Generer une liste des membres pour une activite
  # L'activite est dans le parametre "activite"
  def listeMembre
    id = params[:activite].to_i
    @activite = Activite.find(id)
    @membres = @activite.membres.all.order(:nom, :prenom)
  end

  # Generer une liste des membres pour une activite
  # L'activite est dans le parametre "activite"
  def listeMembreNatation
    @activite = Activite::natation
  end

  # Generer un rapport du nombre de membres par activite
  def sommaire
    @data = Activite.sommaire
  end
  
  private
  
  def activite_params(params)
    params.require(:activite).permit([:code, :description_fr, :description_en, :url_fr, :url_en, :gratuite, :cout])
  end

end
