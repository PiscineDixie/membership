# coding: utf-8
# Controlleur pour les operations que les membres peuvent
# accomplir eux-memes
#

class PublicController < ApplicationController

  layout "public"
  
  # Une authentification pour la famille
  before_action :famille_authenticate, :except => [:login, :login_en, :login_fr, :new, :create]
  
  before_action :set_locale, only: [:login, :login_en, :login_fr, :new, :create]
    
  def set_locale
    I18n.locale =  english? ? :en : :fr
  end
   
  # Valider la permission de completer une activite
  def famille_authenticate
    @famille = nil
    
    # Recuperer le code d'acces de la famille des parametres de la query si present
    id = params[:fam_id]
    if id && !id.empty? then
      @famille = Famille.where("code_acces = :code", {:code => id}).includes([:cotisation, :paiements, :membres, :notes]).take
      if @famille then
        langCookie(nil)
        session[:familleId] = @famille.id;
      end
    end
    
    if @famille.nil? && session[:familleId]
      @famille = Famille.find_by_id(session[:familleId]);
    end
    
    set_locale
    
    # Permettre l'operation si une famille, sinon on va au login
    if @famille.nil? then
      redirect_to :action => 'login'
      return false
    else
      return true 
    end
  end
  
  # Logon. Ceci permet d'identifier la famille a l'aide de donnees personnelles
  def login
    if request.post? then
      if params[:courriel] && !params[:courriel].empty?
        # Trouvez les profils ayant cette adresse.
        fs = Famille.where("courriel1 = :courriel1 or courriel2 = :courriel2", {:courriel1 => params[:courriel], :courriel2 => params[:courriel]})
        if !fs.empty?
          fs.each do |f|
             msg = t(:public_login_link)
             sujet = t(:public_login_sujet)
             FamilleMailer.info(f, sujet, params[:courriel], msg, f.langue).deliver
          end
          flash[:notice] = t(:public_login_sent)
        else
          flash[:notice] = t(:public_login_unk)
        end
      else
        flash[:notice] = t(:public_login_inv) 
      end
      
    end
    
    # On recommence avec le meme formulaire de login
    render 'login'
  end
  
  # L'action equivalente qui affiche la page en anglais
  def login_en
    langCookie('en')
    redirect_to :action => 'login'
  end

  # L'action equivalente qui affiche la page en francais. Reset du cookie.
  def login_fr
    langCookie("fr")
    redirect_to :action => 'login'
  end

  
  def logout
    session.delete(:familleId)
    redirect_to :action => 'login'
  end
  
  def home
  end
  
  # Creer un nouveau profil
  def new
    inEnglish = english?
    @famille = Famille.new
    @famille.langue = inEnglish ? "EN" : "FR"
    @note = ''
  end
  
  # Enregistrer les donnees d'une nouvelle famille.
  def create
    if (params[:cancel])
      redirect_to :action => 'login'
      return
    end
    
    # Recuperer l'information de la famille, des membres et leurs activites
    @famille = Famille.new(famille_params(params))
    @famille.etat = Famille::Etats[0]  # On commence actif
    
    @note = params.has_key?(:note) ? params[:note].strip : ''
    if @note.length > 0
      @famille.notes.build({:auteur => 'famille', :info => @note})
    end
    
    if !valid?(@famille) || !@famille.save
      @famille.membres.build if @famille.membres.empty?
      render 'new'
      return
    end
    
    # Tout a fonctionne. Enregistrer la clef du logon
    langCookie(nil)
    session[:familleId] = @famille.id
    
    # Mettre la famille active. Ceci permet le calcule de la cotisation
    @famille.etat = Famille::Etats[0]
    @famille.calculeCotisation
    @famille.save!
    FamilleMailer.cotisation_notif(@famille, @famille.courriels).deliver
    
    flash[:notice] = t(:public_create_saved)

    if (!@famille.membres.empty? and @famille.cotisationDue() > 0)
      render "shared/_abonnement" , locals: {famille: @famille};
      return
    end

    # Afficher le profil
    redirect_to public_home_path
  end
  
  def show
  end

  def edit
  end

  def update

    if params[:cancel]
      redirect_to public_home_path
      return
    end
    
    @note = params.has_key?(:note) ? params[:note].strip : ''
    cotisationAvant = @famille.cotisationTotal
    if @famille.update(famille_params(params))
      
      # Validation specifique pour le public. Notez que la db est deja a jour.
      @famille.membres
      if !valid?(@famille)
        @famille.save!  # Ceci sauve les corrections faites
        @famille.membres.build if @famille.membres.empty?
        render :edit
        return
      end

      if @note.length > 0
        @famille.notes.build({:auteur => 'famille', :info => @note})
      end
      
      @famille.etat = Famille::Etats[0]
      @famille.calculeCotisation
      @famille.save!
      
      if cotisationAvant != @famille.cotisationTotal
        FamilleMailer.cotisation_notif(@famille, @famille.courriels).deliver
      end
      
      set_locale
      flash[:notice] = t(:public_upd_saved)

      if (!@famille.membres.empty? and @famille.cotisationDue() > 0)
        render "shared/_abonnement", :locals => {:famille => @famille};
      else
        redirect_to '/public/1'
      end
      return
    else
      @famille.membres.build if @famille.membres.empty?
      render :edit
      return
    end
  end

  def payer
    render "shared/_abonnement", :locals => {:famille => @famille};
  end
  
  def aide
  end
  
  # Generer les recu d'impot d'une famille
  # Reconnait les parametre "courriel" et "parent"
  def recu
    if request.post? && params[:parent] && params[:courriel] then
      annee = (Date.today.month > 6 ? Date.today.year : Date.today.year - 1)
      parent = params[:parent]
      to = params[:courriel]
      unless @famille.recus.nil? || @famille.recus.empty?
        FamilleMailer.recu(@famille, @famille.recus, to, parent).deliver
        flash[:notice] = t(:public_recu_sent, to: to)
      else
        flash[:notice] = t(:public_recu_na)
      end
      redirect_to public_home_path
      return;
    end
    
    # On doit avoir une adresse courriel
    if @famille.courriels.empty?
      flash[:notice] = t(:public_recu_email_needed)
      redirect_to :action => 'edit'
      return
    end
    
    # Si on parvient jusqu'ici, on affiche le formulaire
  end
  
  # Generer un recu pour les paiements effectués
  def recupaiement
    recu = RecuPaiement.new(@famille)
    doc = recu.toPDF()
    send_data doc.render, :type => 'application/pdf', :disposition => 'inline', :filename => 'recu-dixie.png'
  end
  

private
  def famille_params(params)
    params[:famille].permit!
  end
  
  # Retourne 'true' si le login s'est fait avec
  def english?
    return @famille.english? if @famille
    return session[:lang] && session[:lang] == 'en'
  end
  
  # Validations pour les choses non-permises par l'interface public
  def valid?(famille)
    if famille.membres.empty?
      flash[:notice] = t(:public_valid_membre)
      return false
    end
    
    plusAge = famille.plusVieuxMembre
    # S'assurer que des billets ne sont permis que si un membre a 10 ans ou plus
    if famille.nombreBillets > 0 && Date.civil(Date.today.year, 8, 1).years_ago(10) < plusAge.naissance
      flash[:notice] = t(:public_valid_ticket) 
      return false;
    end
    
    # S'assurer qu'il y a au moins un membre de la famille suffisament age
    minNaissance = Date.new(Date.today.year, 8, 1).years_ago(Constantes.instance.age_min_individu)
    if plusAge.naissance > minNaissance
      flash[:notice] = t(:public_valid_age, naissance: minNaissance)
      famille.etat = Famille::Etats[1]
      return false
    end
    return true
  end
  
  def langCookie(value)
    if (value)
      session[:lang] = value
    else
      session.delete(:lang)
    end
  end
  
end
