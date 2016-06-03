# coding: utf-8
#
# Controlleur pour les operations d'une famille
#
class FamillesController < ApplicationController
  
  before_action :check_su, :only =>[:debutAnnee, :annulerRabais]
  before_action :check_admin, :only => [:courriel, :recus, :recu, :dues, :destroy, :exp_recus ]
  before_action :authenticate, except: :instructions
  
  # GET /familles
  # GET /familles.xml
  def index
  end

  # GET /familles/1
  # GET /familles/1.xml
  def show
    @famille = Famille.includes([:cotisation, :paiements, :membres, :notes]).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @famille }
    end
  end

  # GET /familles/1/edit
  def edit
    @famille = Famille.find(params[:id])
  end

  # Operation pour creer toute l'information d'une famille dans une page
  # GET /familles/new
  def new
    @famille = Famille.new
  end
  
  # Et le post pour creer toute la famille d'une seule operation
  # Si une erreur de traitement, on re-affiche la form du "new"
  def create
    if (params[:cancel])
      redirect_to(familles_url)
      return;
    end
    
    # Recuperer l'information de la famille, des membres et leurs activites
    @famille = Famille.new(famille_params(params))
    @famille.etat = Famille::Etats[0]  # On commence actif
    if (!@famille.save)
      @famille.membres.build if @famille.membres.empty?
      render :action => 'new'
      return
    end
    
    @famille.calculeCotisation
    redirect_to(@famille)
  end

  # PUT /familles/1
  # PUT /familles/1.xml
  def update
    @famille = Famille.find(params[:id])
      
    if (params[:cancel])
      redirect_to(@famille)
      return;
    end
    
    if @famille.update(famille_params(params))
      flash[:notice] = 'Modifications enregistrées.'
      @famille.calculeCotisation
      redirect_to(@famille)
    else
      @famille.membres.build if @famille.membres.empty?
      render :action => "edit"
    end
  end

  # DELETE /familles/1
  # DELETE /familles/1.xml
  def destroy
    @famille = Famille.find(params[:id])
    if @famille.paiements.empty?
      @famille.destroy
    else
      @famille.etat = 'Inactif'
      @famille.courriel1 = @famille.courriel2 = ''
      @famille.save!
      flash[:notice] = 'Famille désactivée mais non enlevée puisque des paiements ont été enregistrés.'
    end

    respond_to do |format|
      format.html { redirect_to(familles_url) }
      format.xml  { head :ok }
    end
  end
  
  def desactive
    famille = Famille.find(params[:id])
    famille.etat = 'Inactif'
    famille.save!
    if famille.paiements.empty? && famille.cotisation != nil
      famille.cotisation.destroy
    end
    redirect_to(famille)
  end
  
  # Noter que les ecussons sont remis
  def ecussonsRemis
    famille = Famille.find(params[:id])
    famille.cotisation.ecussons_remis = true
    famille.cotisation.save!
    
    note = famille.notes.new
    note.info = 'Ecussons remis par moi'
    note.auteur = User.sessionUserId(session[:user])
    note.save!
     
    redirect_to(famille)
  end
  
  # Operations pour rechercher une famille grace a son numero de telephone a Lachine
  def recherche
    key = params[:key];
    champ = params[:champ]
    
    if key.empty?
      redirect_to(familles_url)
      return
    end
    
    @familles = case champ
      when 'Tél' then Famille.where("tel_soir regexp :tel1 or tel_jour regexp :tel2", {:tel1 => key, :tel2 => key})
      when 'CP' then Famille.where("code_postal regexp :cp", {:cp => key})
      when 'Courriel' then Famille.where("courriel1 regexp :courriel1 or courriel2 regexp :courriel2", {:courriel1 => key, :courriel2 => key})
      when 'Nom' then   Famille.find_by_sql([
          "select distinct familles.* FROM familles inner join membres as m on familles.id = m.famille_id WHERE (nom regexp :nom or prenom regexp :prenom)",
            {:nom => key, :prenom => key}])
    end
    
    if @familles.size == 1
      @famille = @familles[0]
      redirect_to(@famille)
      return
    elsif !@familles.empty?
      tmpF = @familles.sort_by { |f| f.nom }
      @familles = tmpF
      render(:action => 'index')
      return;
    else
      flash[:notice] = 'Aucun dossier pour ce critère de recherche.'
      redirect_to(familles_url)
    end
  end
  

  # Rapport statistiques des membres
  def stats
  end

  # Expedier un courriel. Le get fournit le formulaire, le post genere le courriel.
  def courriel
    @msg = ''
    @sujet = ''
    @langue = ''
    @testAddr = ''
    @msg = params[:msg].strip if params[:msg]
    @sujet = params[:sujet].strip if params[:sujet]
    @langue = params[:langue] if params[:langue]
    @testAddr = params[:testAddr].strip if params[:testAddr]
    
    if request.post?
      
      if (params[:cancel])
        redirect_to(familles_url)
        return;
      end

      valide = true
      if @msg.empty? || @sujet.empty?
        flash[:notice] = "Le message et le sujet doivent être fournis."
        valide = false
      end
      
      @langue = 'ml' if @langue == 'Toutes'
      
      erreurs = Array.new
      
      if valide
        # Expedie ce courriel a toutes les adresses
        cnt = 0
        if !@testAddr.empty? then
          # Expedier ce courriel a la liste d'adresses. Si moins de 3, peut correspondre a une famille
          to = @testAddr.split(/[ ,]\s*/)
          if (to.length <= 2)
            uneAddr = to[0]
            famille = Famille.where("courriel1 = :addr or courriel2 = :addr", {:addr => uneAddr}).take
          end
          FamilleMailer.info(famille, @sujet, to, @msg, @langue).deliver_now
          cnt = 1
        else
          # Expedier ce courriel aux familles. Filtre sur les activites
          actId = params[:activite].to_i
          
          if actId == 100 then # Toutes les familles
            familles = @langue == 'ml' ? Famille.all.find_each : Famille.langue(@langue).find_each 
          elsif actId == 101 then
            familles = Famille.inactives
            familles = familles.langue(@langue) unless @langue == 'ml'
            familles = familles.find_each
          elsif actId == 102 then
            familles = Famille.actives
            familles = familles.langue(@langue) unless @langue == 'ml'
            familles = familles.find_each
          elsif actId == 103 then # Avec cotisation due
            familles = Famille.actives
            familles = familles.langue(@langue) unless @langue == 'ml'
            familles = familles.to_a.select { |f| f.cotisationDue > 0 }
          else
            familles = @langue == 'ml' ? Famille.all.find_each : Famille.langue(@langue).find_each
          end
          
          familles.each do | f |
            # Exclure les familles qui ne participent pas a cette activite
            trouveMembre = actId >= 100
            if !trouveMembre
              f.membres.each do | m |
                if m.activite?(actId)
                  trouveMembre = true
                  break
                end
              end
            end
            
            # Expedier un courriel aux adresses de la famille
            if trouveMembre && !f.courriels.empty?
              begin
                FamilleMailer.info(f, @sujet, f.courriels, @msg, @langue, cnt == 0).deliver_now
                cnt = cnt + 1
              rescue Exception => e
                erreurs << f.courriels
                logger.error("Exception dans mailer pour: #{f.courriels}")
                logger.error(e)
              end
            end
          end
        end
        
        msg = cnt.to_s + ' courriels expédiés.'
        unless erreurs.empty?
          msg = msg + "; erreurs: " + erreurs.to_s
        end
        flash[:notice] = msg
          
        redirect_to(familles_url)
        return
      end
    end
    
    # Fournir la template pour entrer les donnees du courriel
  end

  # Operation pour le debut d'une annee
  def debutAnnee
    Famille.debutAnnee
    flash[:notice] = "Remise à zéro pour début d'année complétée"
    redirect_to(familles_url)
  end
  
  
  # Operation pour generer un rapports des montants dues
  def dues
    @familles = Famille.famillesActives
  end
  
  # Operation pour generer les recus d'impot pour la condition physique des enfants
  # pour toute les familles
  def recus
    annee = Date.today.month > 6 ? Date.today.year : Date.today.year - 1
    Famille.includes([:membres, :cotisation, :paiements]).each do |famille|
      famille.genereRecus(annee)
    end
    flash[:notice] = "Reçus générés dans la base de données."
    redirect_to(familles_url)
  end
  
  # Operation pour expedier les recus pour les familles
  def exp_recus
    annee = Date.today.month > 6 ? Date.today.year : Date.today.year - 1
    Famille.includes(:recus).each do |famille|
      recus = famille.recus.where("annee = :annee", {:annee => annee});
      unless recus.empty? || famille.courriels.empty?
        parent = famille.membres.order(:naissance).take.prenomNom
        FamilleMailer.recu(famille, recus, famille.courriels, parent).deliver_now
      end
    end
    flash[:notice] = "Courriels expédiés à tous les membres éligibles."
    redirect_to(familles_url)
  end
  
  # Generer les recu d'impot d'une famille
  # Reconnait les parametre "annee" et "parent"
  def recu
    famille = Famille.includes(:membres, :cotisation, :paiements).find(params[:id])
    if (famille.courriels.empty?)
      flash[:notice] = "La famille doit avoir au moins une adresse courriel pour l'expédition des reçus."
      redirect_to(famille)
      return;
    end
    
    annee = params[:annee]
    if annee.nil?
      annee = (Date.today.month > 6 ? Date.today.year : Date.today.year - 1)
    else
      annee = annee.to_i
    end
    famille.genereRecus(annee)
    recus = famille.recus.where("annee = :annee", {:annee => annee});
    if !recus.empty?
      parent = params[:parent] || famille.membres.order(:naissance).take.prenomNom
      FamilleMailer.recu(famille, recus, famille.courriels, parent).deliver_now
      flash[:notice] = "Courriels expédiés à l'adresse(s): " + famille.courriels.to_s
    else
      flash[:notice] = "Non éligible pour un reçu."
    end
    redirect_to(famille)
  end
  
  # Produire un rapport pour toutes les familles ayant calcule une cotisation
  def cotisations
    @familles = Famille.where("etat = ?", Famille::Etats[0]).sort_by { |f| [f.cotisation.created_at, f.nom] }
  end


  # Produire un rapport pour toutes les familles inactives
  def inactifs
    @familles = Famille.where("etat = ?", Famille::Etats[1]).sort_by { |f| f.nom }
  end

  # Produire un rapport pour toutes les familles sans courriels
  def pas_courriels
    @familles = Famille.where("courriel1 = '' and courriel2 = ''").sort_by { |f| f.nom }
  end
  
  # Annuler les rabais de pre-inscription
  def annulerRabais
    if Constantes.instance.finPreInscription > Date.today
      flash[:notice] = "Impossible d'annuler le rabais avant la fin de la période de rabais."
      redirect_to(familles_url)
      return;
    end
    
    Famille.annulerRabais
    flash[:notice] = "Cotisations modifiées. Courriels expédiés."
    redirect_to(familles_url)
  end
  
  # Rapport des ecussons et billets
  def ecussons
    @familles = Famille.where("etat = :etat", {:etat => Famille::Etats[0]}).sort_by {
      |f| f.paiements.first.nil? ? f.cotisation.created_at : f.paiements.first.created_at
    }
  end
  
  private
  
  def famille_params(params)
    params.require(:famille).permit!
  end
end
