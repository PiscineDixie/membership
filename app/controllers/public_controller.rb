# coding: utf-8
# Controlleur pour les operations que les membres peuvent
# accomplir eux-memes
#

class PublicController < ApplicationController

  layout "public"
  
  # Une authentification pour la famille
  before_action :famille_authenticate, :except => [:login, :login_en, :login_fr, :new, :create]
  
  # Valider la permission de completer une activite
  def famille_authenticate
    @famille = nil
    
    # Recuperer le code d'acces de la famille des parametres de la query si present
    id = params[:fam_id] ? params[:fam_id] : cookies[:fam_id]
    if id && !id.empty? then
      @famille = Famille.where("code_acces = :code", {:code => id}).includes([:cotisation, :paiements, :membres, :notes]).take
      if @famille then
        langCookie(nil)
        famIdCookie(id)
      end
    end
    
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
             msg = f.english? ? "Please use the link below to access your profile" : "SVP Utilisez le lien ci-dessous pour accéder à votre dossier."
             sujet = f.english? ? "Link to Profile" : "Lien pour accès au dossier"
             FamilleMailer.info(f, sujet, params[:courriel], msg, f.langue).deliver
          end
          flash[:notice] = english? ? "Email was sent." : "Un courriel a été expédié."
        else
          flash[:notice] = english? ? "Unknown email address." : "Aucun profil ne correspond à cette adresse courriel."
        end
      else
        flash[:notice] = english? ? "Please enter a valid email address." : "Veuillez-SVP entrer une adresse courriel."
      end
      
    end
    
    # On recommence avec le meme formulaire de login
    render :content_type => 'text/html', :template => localized('login', (english? ? 'en' : 'fr'))
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
    famIdCookie(nil)
    redirect_to :action => 'login'
  end
  
  # Creer un nouveau profil
  def new
    inEnglish = english?
    @famille = Famille.new
    @famille.langue = inEnglish ? "EN" : "FR"
    @note = ''
    render :content_type => 'text/html', :template => localized('new', @famille.langue)
  end
  
  # Enregistrer les donnees d'une nouvelle famille.
  def create
    # Recuperer l'information de la famille, des membres et leurs activites
    @famille = Famille.new(famille_params(params))
    @famille.etat = Famille::Etats[0]  # On commence actif
    
    @note = params.has_key?(:note) ? params[:note].strip : ''
    if @note.length > 0
      @famille.notes.build({:auteur => 'famille', :info => @note})
    end
    
    if !valid?(@famille) || !@famille.save
      @famille.membres.build if @famille.membres.empty?
      render :content_type => 'text/html', :template => localized('new', @famille.langue)
      return
    end
    
    # Tout a fonctionne. Enregistrer la clef du logon
    famIdCookie(@famille.code_acces)
    langCookie(nil)
    
    # Mettre la famille active. Ceci permet le calcule de la cotisation
    @famille.etat = Famille::Etats[0]
    @famille.calculeCotisation
    @famille.save!
    FamilleMailer.cotisation_notif(@famille, @famille.courriels).deliver
    
    flash[:notice] = @famille.english? ? 
      "Your profile is saved." :
      "Votre profil est enregistré."

    if (!@famille.membres.empty? and @famille.cotisationDue() > 0)
      render :content_type => 'text/html', :template => "shared/abonnement_" + @famille.langue.downcase + ".text.html.erb", :locals => {:famille => @famille};
      return
    end

    # Afficher le profil
    redirect_to :action => :show
  end
  
  def show
    render :content_type => 'text/html', :template => localized('show', @famille.langue)
  end

  def edit
    render :content_type => 'text/html', :template => localized('edit', @famille.langue)
  end

  def update
    @note = params.has_key?(:note) ? params[:note].strip : ''
    cotisationAvant = @famille.cotisationTotal
    if @famille.update(famille_params(params))
      
      # Validation specifique pour le public. Notez que la db est deja a jour.
      @famille.membres(true)
      if !valid?(@famille)
        @famille.save!  # Ceci sauve les corrections faites
        @famille.membres.build if @famille.membres.empty?
        render :content_type => 'text/html', :template => localized('edit', @famille.langue)
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
      
    flash[:notice] = @famille.english? ? 
      "Your profile is updated." :
      "Votre profil est modifié."

      if (!@famille.membres.empty? and @famille.cotisationDue() > 0)
        render :content_type => 'text/html', :template => "shared/abonnement_" + @famille.langue.downcase + ".text.html.erb", :locals => {:famille => @famille};
      else
        redirect_to :action => :show
      end
      return
    else
      @famille.membres.build if @famille.membres.empty?
      render :content_type => 'text/html', :template => localized('edit', @famille.langue)
      return
    end
  end

  def aide
    render :content_type => 'text/html', :template => localized('aide', @famille.langue)
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
        flash[:notice] = english? ? "Email sent to address: " + to : "Courriel expédié à l'adresse: " + to
      else
        flash[:notice] = english? ? "Your family is not eligible for a receipt." : "Non éligible pour un reçu."
      end
      redirect_to :action => 'aide'
      return;
    end
    
    # On doit avoir une adresse courriel
    if @famille.courriels.empty?
      flash[:notice] = english? ? 
        "You must first enter a valid email address in your profile." : 
        "Vous devez d'abord ajouter une adresse courriel valide à votre profil."
      redirect_to :action => 'edit'
      return
    end
    
    # Si on parvient jusqu'ici, on affiche le formulaire
    render :content_type => 'text/html', :template => localized('recu', @famille.langue)
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
    return cookies[:lang] && cookies[:lang] == 'en'
  end
  
  def localized(name, langue)
    return'public/' + name + '.' + langue.downcase
  end
  
  # Validations pour les choses non-permises par l'interface public
  def valid?(famille)
    if famille.membres.empty?
      flash[:notice] = famille.english? ?
        "Please add family members to your profile." :
        "SVP ajouter au moins un membre à votre profil familial."
      return false
    end
    
    plusAge = famille.plusVieuxMembre
    # S'assurer que des billets ne sont permis que si un membre a 10 ans ou plus
    if famille.nombreBillets > 0 && Date.civil(Date.today.year, 8, 1).years_ago(10) < plusAge.naissance
      flash[:notice] = famille.english? ? 
      "Tickets purchasing requires that one family member must be at least 10 years old on the first of August." : 
      "L'achat de billets n'est permis que si un membre de la famille a plus de 10 ans le premier août."
      famille.cotisation.nombre_billets = 0
      return false;
    end
    
    # S'assurer qu'il y a au moins un membre de la famille suffisament age
    minNaissance = Date.new(Date.today.year, 8, 1).years_ago(Constantes.instance.age_min_individu)
    if plusAge.naissance > minNaissance
      flash[:notice] = famille.english? ? 
        "At least one family member must be born before %s to create an individual membership. Please add at least one parent." % minNaissance :
        "Au moins un membre de la famille doit être né avant le %s pour souscrire à un abonnement individuel. SVP ajoutez au moins un parent." % minNaissance
      famille.etat = Famille::Etats[1]
      return false
    end
    return true
  end
  
  def langCookie(value)
    if (value)
      cookies[:lang] = { :value => value, :path => "/public"}
    else
      cookies.delete(:lang)
    end
  end
  
  def famIdCookie(value)
    if (value)
      cookies[:fam_id] = { :value => value, :path => "/public"}
    else
      cookies.delete(:fam_id);
    end
  end
end
