# coding: utf-8
class NotesController < AdminController

  # Pour permettre d'acceder lorsque precede d'une famille dans le URL (REST)
  before_action :load_famille, :only => [:show, :new, :create]
  before_action :authenticate
  
  def load_famille
    @famille = Famille.find(params[:famille_id])
  end
  
  # GET /notes/1
  # GET /notes/1.xml
  def show
    @note = @famille.notes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @note }
    end
  end

  # GET /notes/new
  # GET /notes/new.xml
  def new
    @note = @famille.notes.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @note }
    end
  end


  # POST /notes
  # POST /notes.xml
  def create
    if (params[:cancel])
      redirect_to(famille_path(@famille))
      return;
    end
    
    @note = @famille.notes.new
    @note.info = params[:note][:info]
    @note.auteur = User.sessionUserId(session[:user])

    respond_to do |format|
      if @note.save
        flash[:notice] = 'Note was successfully created.'
        format.html { redirect_to(famille_path(@famille)) }
        format.xml  { render :xml => @note, :status => :created, :location => @note }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Rapport des notes durant une periode
    # Les revenus pour l'intervalle donnée
  # params[:debut] - date du début du rapport
  # params[:fin] - date de la find du rapport
  def rapport
    @debut = Date.parse(params['debut'])
    @fin   = Date.parse(params['fin'])
    @notes = Note.order("famille_id, date").
              where("date >= :minDate and date <= :endDate", 
              {:minDate => @debut.to_formatted_s(:db), :endDate => @fin.to_formatted_s(:db)})
  end

end
