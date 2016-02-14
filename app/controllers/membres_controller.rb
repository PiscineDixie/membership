# coding: utf-8
class MembresController < ApplicationController
  
  # Pour permettre d'acceder lorsque precede d'une famille dans le URL (REST)
  before_action :load_famille, :except => [:seniors, :index]
  before_action :authenticate
  
  def load_famille
    @famille = Famille.find(params[:famille_id])
  end
  
  # GET /membres/1
  # GET /membres/1.xml
  def show
    @membre = @famille.membres.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @membre }
    end
  end

  # GET /membres/new
  # GET /membres/new.xml
  def new
    @membre = @famille.membres.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membre }
    end
  end

  # GET /membres/1/edit
  def edit
    @membre = @famille.membres.find(params[:id])
  end

  # POST /membres
  # POST /membres.xml
  def create
    @membre = @famille.membres.build(membre_params(params))
    @membre.saveActivites(params)

    respond_to do |format|
      if @membre.save
        flash[:notice] = 'Membre was successfully created.'
        format.html { redirect_to([@famille, @membre]) }
        format.xml  { render :xml => @membre, :status => :created, :location => @membre }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @membre.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /membres/1
  # PUT /membres/1.xml
  def update
    @membre = @famille.membres.find(params[:id])
    @membre.saveActivites(params)

    respond_to do |format|
      if @membre.update_attributes(membre_params(params))
        flash[:notice] = 'Membre was successfully updated.'
        format.html { redirect_to([@famille, @membre]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membre.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /membres/1
  # DELETE /membres/1.xml
  def destroy
    @membre = Membre.find(params[:id])
    @membre.destroy

    respond_to do |format|
      format.html { redirect_to(famille_url(@famille)) }
      format.xml  { head :ok }
    end
  end
  
  # Rapport de tous les membres
  def index
    @membres = Membre.order('nom, prenom')
  end
  
  # Rapport des membres seniors.
  def seniors
    # Faire une liste approximative de la db
    @membres = Membre.where("naissance < ?", Date.civil(Date.today.year - 60, 12, 31).to_s(:db)).order('nom, prenom').to_a
    @membres.reject! { |m| !m.senior? } unless @membres.empty?
  end
  
  private
  
  def membre_params(params)
    params.require(:membre).permit([:prenom, :nom, :naissance, :ecusson, :cours_de_natation, :session_de_natation])
  end
end
