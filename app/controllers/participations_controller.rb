# coding: utf-8
class ParticipationsController < AdminController
  before_action :check_admin, except: :index
  before_action :authenticate, only: :index

  # GET /participations
  # GET /participations.xml
  def index
    @participations = Participation.order(:description_fr)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @participations }
    end
  end

  # GET /participations/1
  # GET /participations/1.xml
  def show
    @participation = Participation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @participation }
    end
  end

  # GET /participations/new
  # GET /participations/new.xml
  def new
    @participation = Participation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @participation }
    end
  end

  # GET /participations/1/edit
  def edit
    @participation = Participation.find(params[:id])
  end

  # POST /participations
  # POST /participations.xml
  def create
    if (params[:cancel])
      redirect_to(participations_url)
      return;
    end
    
    @participation = Participation.new(participation_params(params))

    respond_to do |format|
      if @participation.save
        flash[:notice] = 'Participation was successfully created.'
        format.html { redirect_to(@participation) }
        format.xml  { render :xml => @participation, :status => :created, :location => @participation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @participation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participations/1
  # PUT /participations/1.xml
  def update
    @participation = Participation.find(params[:id])

    if (params[:cancel])
      redirect_to(@participation)
      return;
    end
    
    respond_to do |format|
      if @participation.update(participation_params(params))
        flash[:notice] = 'Activite was successfully updated.'
        format.html { redirect_to(@participation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @participation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /participations/1
  # DELETE /participations/1.xml
  def destroy
    @participation = Participation.find(params[:id])
    @participation.destroy

    respond_to do |format|
      format.html { redirect_to(participations_url) }
      format.xml  { head :ok }
    end
  end
  
  # Generer une liste des membres pour une participation
  # L'participation est dans le parametre "participation"
  def listeMembre
    id = params[:participation].to_i
    @participation = Participation.find(id)
    @membres = @participation.membres.order('nom, prenom')
  end

  private
  
  def participation_params(params)
    params.require(:participation).permit([:description_fr, :description_en])
  end
end
