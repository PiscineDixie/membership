# coding: utf-8
class ActivitesController < AdminController
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
    # au debut on pouvait avoir un frais d'activite pour une famille. n'existe plus. hidden dans la view.
    @activite.gratuite = true
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
    if @activite.save
      flash[:notice] = 'Activite mise à jour.'
      redirect_to(@activite)
    else
      render :action => "new"
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
    
    if @activite.update(activite_params(params))
      flash[:notice] = 'Activite mise à jour.'
      redirect_to(@activite)
    else
      render :action => "edit"
    end
  end

  # DELETE /activites/1
  # DELETE /activites/1.xml
  def destroy
    @activite = Activite.find(params[:id])
    @activite.destroy
    redirect_to(activites_url)
  end
  
  # Generer une liste des membres pour une activite
  # L'activite est dans le parametre "activite"
  def listeMembre
    id = params[:activite].to_i
    @activite = Activite.find(id)
    @membres = @activite.membres.all.order(:nom, :prenom)
  end

  # rapport des groupes de natation
  def listeMembreNatation
    @activite = Activite::natation
  end

  # Generer un rapport du nombre de membres par activite
  def sommaire
    @data = Activite.sommaire
  end
  
  private
  
  def activite_params(params)
    params.require(:activite).permit([:code, :description_fr, :description_en, :url_fr, :url_en, :gratuite, :cout, :cout2])
  end

end
