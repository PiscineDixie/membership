# coding: utf-8
require 'digest/sha2'
require 'recu'

class Famille < ActiveRecord::Base
  # Etats d'une famille:
  #  - inactif: famille connue mais non-re-inscrite
  #  - actif:   ayant complété son inscription
  Etats = %w(Actif Inactif)
  Langue = %w(FR EN)
  
  # Validation
  validates_presence_of :adresse1, :ville, :message => 'doit être fournie'
  validates_inclusion_of :etat, :in => Famille::Etats
  validates_inclusion_of :langue, :in => Famille::Langue
  validates_format_of :courriel1, :courriel2, :allow_blank => true, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create, :message => 'adresse invalide'
  validates_length_of :province, :is => 2, :message => 'utiliser le code à deux lettres (e.g., QC)'
  validates_length_of :code_postal, :is => 6, :message => 'doit avoir 6 caractères'
  validates :tel_soir, length: { maximum: 20}
  validates :tel_jour, length: { maximum: 20}
  validates_format_of :code_postal, :with => /\A[A-Z][1-9][A-Z][1-9][A-Z][1-9]\z/, :message => 'doit contenir des chiffres et des majuscules'
  validates_size_of :membres, :minimum => 1, :on => :create, :message => '-- au moins un'
  
  has_many :membres, inverse_of: :famille, dependent: :destroy  # Destroy pour mettre a jour le lien avec les activites
  has_one  :cotisation, inverse_of: :famille, dependent: :delete
  has_many :paiements, inverse_of: :famille, dependent: :delete_all
  has_many :notes, inverse_of: :famille, dependent: :delete_all
  has_many :recus, inverse_of: :famille, dependent: :delete_all
  has_many :commandes, inverse_of: :famille, dependent: :delete_all
  
  scope :english, -> { where(langue: 'EN') }
  scope :french, -> { where(langue: 'FR') }
  scope :langue, -> (ln) { where("langue = ?", ln) }
  scope :actives, -> { where(etat: 'Actif') }
  scope :inactives, -> { where(etat: 'Inactif') }
    
  # Generer un code d'access pour la famille
  before_create :assign_code
  def assign_code
    self.code_acces = Digest::SHA256.hexdigest(self.adresse1 + rand(255).to_s)
  end
  
  
  # Creer une famille avec certains champs par default
  def initialize(parms = nil, options = {})
    tmpMembres = parms && parms.delete(:membres) || nil
    tmpCotisation = parms && parms.delete(:cotisation) || nil
    cleanParms(parms)
    super
    
    if tmpMembres then
      tmpMembres.each do | idx, mp |
        unless mp[:prenom].empty? then
          mp.delete(:id)
          self.membres.build(mp)
        end
      end
    end
    
    self.build_cotisation(tmpCotisation) if tmpCotisation
    
    # Les valeur par defaut
    if !parms then
      self.ville = 'Lachine'
      self.province = 'QC'
      self.langue = 'FR'
      self.etat = 'Inactif'
      self.membres.build
      self.build_cotisation
    end
  end
  
  
  # Mettre a jour les parametres d'une famille et sous-objets si presents
  def update(parms)
    
    # On met le tout dans une transaction afin que ca passe ou ca casse.
    # On laisse les erreurs dans le modele afin de les corriger.
    # Malheureusement les activites des membres sont perdus a cause du HABTM.
    transaction do
      
      # Premierement mettre a jour l'information de la famille
      # C'est tres important de faire cette etape en premier sinon on ne peut
      # voir les messages d'erreurs pour les membres.
      tmpMembres = parms.delete(:membres)
      tmpCotisation = parms.delete(:cotisation)
      cleanParms(parms)
      super
      
      # Deuxiemement mettre a jour les membres et leurs activites
      if tmpMembres then
        tmpMembres.each do | idx, mp |
          fId = mp.delete(:id) # La forme inclus le numero du membre
          if (!fId || fId.empty?) && (mp[:prenom].nil? || mp[:prenom].empty?) then
            # La forme contient un nouveau membre mais sans prenom, on l'ignore
            ;
          elsif (!fId || fId.empty?) then
            # C'est un nouveau membre
            m = self.membres.create(mp)
            m.errors.each do | attr, msg |
              errors[:base] << msg;
            end
          elsif (!mp[:prenom] || mp[:prenom].empty?) then
            # Un membre avec un record id n'a plus de prenom. On l'enleve.
            self.membres.delete(Membre.find(fId.to_i))
          else
            # Enregistrer les modifications d'un membre existant
            m = self.membres.find(fId.to_i)
            m.update(mp)
            m.errors.each do | attr, msg |
              errors[:base] << msg;
            end
          end
        end # pour tous les membres
      end # if tmpMembres
      
      if self.membres.empty?
        errors[:base] << "Au moins un membre par famille"
        self.reload
      end
      
      # Mettre a jour l'information de cotisation. Pas d'erreurs possible ici
      # puisque seulement le nombre de livrets.
      unless tmpCotisation.nil?
        if self.cotisation
          self.cotisation.update(tmpCotisation)
        else
          self.build_cotisation(tmpCotisation)
        end
      end
      
      # Si 'res' == false, il s'est produit une erreur de validation en quelque part
      # et nous voulons mettre fin a cette transaction
      unless errors.empty?
        raise ActiveRecord::Rollback
      end
    end  # fin transaction
    
    return errors.empty?
  end
  
  # Modifier les input parms pour eviter les erreurs stupides
  def cleanParms(parms)
      parms[:code_postal] = parms[:code_postal].upcase.delete(' ') if parms && parms[:code_postal];
  end
  
  # Faire un nom de famille avec les noms de famille des membres
  # On choisis le nom qui revient le plus souvent
  def nom
    return "" if self.membres.empty?
    
    # Construire un hash avec nom => count et ordonner en ordre croissant de frequence
    noms = Hash.new(0);
    self.membres.each { | m |  noms[m.nom]+=1 }
    ordered = noms.sort { |a,b| a[1] != b[1] ? a[1] <=> b[1] : a[0] <=> b[0] } 
    
    # Retourner le nom le plus frequent
    return ordered[-1][0] if ordered.size == 1 or ordered[-1][1] > ordered[-2][1]
    
    # Si un nom avec un trait d'union, le retourner
    ordered.each do |n|
      if n[0].index('-')
        return n[0]
      end
    end
    
    # Si seulement 2 noms, les retourner avec un trait d'union entre le deux
    if ordered.size == 2
      return ordered[0][0] + "-" + ordered[1][0]
    end
    
    #Retourner le premier nom (plus petit en ordre alphabetique)
    return ordered[0][0]
  end
  
  def active?
    return self.etat == 'Actif'
  end
  
  # Retourne true si la famille est consideree en regle: cotisation au moins partiellement paye ou nulle
  def enRegle?
    self.paiementTotal > 0 || self.cotisationDue == 0 || (!self.cotisation.nil? && self.cotisation.cotisation_exemption > 50)
  end
  
  # Retourne true si la famille est inscrite mais n'a pas encore payee
  def inscrite?
    self.paiementsTotal == 0 and !self.enRegle
  end
  
  def english?
    return self.langue == 'EN'
  end
    
  # Retourne une array des prenom-nom de tous les membres
  def prenomNoms
    res = Array.new
    self.membres.each { | m | res << m.prenomNom }
    res
  end
  
  # Retourne une array avec les adresses courriels valides de la famille
  def courriels
    addrs = []
    addrs << self.courriel1 unless self.courriel1.nil? or self.courriel1.empty?
    addrs << self.courriel2 unless self.courriel2.nil? or self.courriel2.empty?
    addrs
  end
  
  # Retourne true si au moins un membre de la famille a des activites non-gratuite
  def ontDesActivites?
    self.membres.each do | m |
      if m.aDesActivites?
        return true
      end
    end
    return false
  end
  
  # Retourne la date de naissance du plus vieux membre
  def plusVieuxMembre
    membre = nil
    self.membres.each { | m |  membre = m if membre.nil? || membre.naissance > m.naissance }
    return membre
  end
  
  def ecussons(nomEcusson)
    return self.membres.where("ecusson = ?", nomEcusson).count
  end
  
  def paiementTotal
    return self.paiements.empty? ? 0 : self.paiements.sum(:montant)
  end
  
  # Nous n'avons pas de facon de savoir si les paiements etaient pour une cotisation ou
  # pour un produit.
  def cotisationDue
    return totalDu
  end
  
  def nombreBillets
    return 0 if self.cotisation.nil?
    return self.cotisation.nombre_billets
  end
  
  def cotisationTotal
    return 0 if self.cotisation.nil?
    return self.cotisation.total
  end
  
  def commandesDues
    return self.commandes.reduce(0.0) { |s, c| s + c.due }
  end
  
  def commandesTotal
    return self.commandes.reduce(0.0) { |s, c| s + c.total }
  end
  
  def totalDu
    return cotisationTotal + commandesTotal - paiementTotal
  end
  
  # On essaie d'appliquer le paiement a une commande
  # Le cas que nous devons considerer survient lorsqu'un enfant est inscrit
  # ou cours de sauvetage, qu'il n'est pas encore paye et qu'il ne le sera pas
  # avant le debut du cours. Il faut quand meme qu'un paiement soit applique aux
  # commandes meme si la cotisation n'est alors pas consideree comme toute reglee.
  def paiementDeCommandes(paiement)
    # Premierement appliquer a une commande du meme montant
    self.commandes.each do |c|
      if c.due == paiement.montant
        c.withPaiement(paiement)
        return
      end
    end
    
    # Deuxiemement, consider le montant en sus de la cotisation
    extraPaie = paiementTotal - cotisationTotal
    self.commandes.each do | c | 
      if c.due <= extraPaie
        extraPaie = extraPaie - c.due
        c.withPaiement(paiement)
      end
    end
  end
  
  # Un paiement est annule.
  # Pour la cotisation, rien a faire
  # Pour les commandes, il faut changer leur etat 
  def annulationPaiement(paiement)
    self.commandes.each do | c |
      if !c.paiement.nil? && c.paiement.id == paiement.id
        c.annulationPaiement
      end
    end
  end
  
  # Calcul de la cotisation pour l'annee. Delegue a l'objet Cotisation.
  # Cotisation est cree si pas deja present.
  def calculeCotisation
    self.cotisation = Cotisation.new if self.cotisation.nil?
    self.cotisation.calcule
    self.cotisation.save!
    
    # Mettre a l'etat actif si le montant est > 0.
    self.etat = 'Actif' if self.cotisation.total > 0
    self.save!
  end
  
  
  # Generer les recus d'impot pour la famille
  def genereRecus(annee = nil)
    
    # Annee est l'annee precedente sauf si specifiee
    annee = Date.today().year - 1 if annee.nil?
    
    # Premierement enlever les recus existants pour l'annee
    recusAnnee = self.recus.where("annee = ?", annee)
    if !recusAnnee.empty? then
      self.recus.delete(recusAnnee)
      self.save!
    end
    
    return if self.cotisation.nil? || self.cotisation.total <= 0

    return if self.paiements.empty?
    return if cotisationDue > 0
    
    self.membres.each do | membre |
      mc = MontantCotisation.new
      montant = mc.montantRecu(self, membre, annee)
      if montant > 0
        r = Recu.new()
        r.annee = annee
        r.info = 'CICP'
        r.prenom = membre.prenom
        r.nom = membre.nom
        r.naissance = membre.naissance
        r.montant = montant
        r.montant_recu = self.paiements[0].created_at
        self.recus << r
      end
    end
    self.save!
  end
  
  
  # Retourne une array avec les familles selon la categorie donnee
  Categories = [:inactif, :enRegle, :inscrit]
  def self.famillesParCat(cat)
    case cat
    
    when :inactif
      fs = Famille.where("etat = 'Inactif'").includes(:membres)
      
    when :enRegle
      fs = Famille.where("etat = 'Actif'").includes([:membres, :cotisation, :paiements]).to_a
      fs.delete_if { |f| !f.enRegle?}
      
    when :inscrit
      fs = Famille.where("etat = 'Actif'").includes([:membres, :cotisation, :paiements]).to_a
      fs.delete_if { |f| f.enRegle?}
    end
  end
  
  # Les actives: enRegle + inscrites
  def self.famillesActives
    return Famille.where("etat = 'Actif'").includes(:membres)
  end
  
  # Retourne le nombre de famille actives. Une famille a au moins deux membres non-senior
  def self.nombreFamilles(cat)
    fCnt = 0
    famillesParCat(cat).each do | f |
      if f.cotisation
        fCnt = fCnt + 1 if f.cotisation.familiale
      else
        mCnt = 0
        f.membres.each do | m |
          mCnt = mCnt + 1 unless m.senior?
        end
        fCnt = fCnt + 1 unless mCnt < 2
      end
    end
    return fCnt;
  end
  
  
  # Retourne le nombre de d'abonne individuel. Ce sont des familles de 1 individu non senior
  def self.nombreIndividus(cat)
    iCnt = 0
    famillesParCat(cat).each do | f |
      iCnt = iCnt + 1 if f.membres.size == 1 and !f.membres[0].senior?
    end
    return iCnt;
  end
  
  # Retourne le nombre de membres
  def self.nombreMembres(cat)
    mCnt = 0
    famillesParCat(cat).each { |f| mCnt = mCnt + f.membres.size }
    mCnt
  end
  
  # Nombre d'abonnes avec le rabais des seniors
  def self.nombreSeniors(cat)
    sCnt = 0
    famillesParCat(cat).each do |f|
      f.membres.each { |m| sCnt = sCnt  + 1 if m.senior? } unless f.cotisation and f.cotisation.familiale
    end
    sCnt
  end
  
  def self.nombresActivites(cat)
    aCnt = 0
    famillesParCat(cat).each do |f|
      f.membres.each { |m| aCnt = aCnt + m.activites.size }
    end
    aCnt
  end
  
  
  # Retourner la listes des courriels
  def self.adressesCourriel(langue, activiteId)
    if langue == 'Toutes'
      familles = Famille.where("etat = 'Actif'").includes(:membres)
    else
      familles = Famille.where("etat = 'Actif' and langue = ?", langue).includes(:membres)
    end
    
    addrs = []
    if (activiteId == 0)
      familles.each { | f | addrs = addrs.concat(f.courriels) }
    else
      # On doit se contenter des membres pour une activite donne
      familles.each do | f |
        f.membres.each do | m |
          if m.activite?(activiteId)
            addrs = addrs.concat(f.courriels)
            break
          end
        end
      end
    end
    return addrs
  end
  
  # Debut d'annee. Le traitement est le suivants
  #  - toutes les familles dont l'etat est 'Inactif' sont enlevees
  #  - toutes celles dont l'etat est 'Actif' deviennent inactives
  #  - la cotisation est enlevee
  #  - Toutes les notes et les paiements sont enlevees.
  #  - Toutes les activites sont enlevees.
  def self.debutAnnee
    # Debarasse des anciens recus
    Recu.destroy_all
    
    # Debarasse des familles inactives.
    Famille.where("etat = 'Inactif'").each do |f|
      f.destroy
    end
    
    # Creer les nouveau recus
    annee = Date.today.month > 6 ? Date.today.year : Date.today.year - 1
    Famille.includes([:membres, :cotisation, :paiements, :commandes]).each do |famille|
      famille.genereRecus(annee)
    end
    
    # Effacer les donnees annuelles
    Paiement.destroy_all
    Note.destroy_all
    Cotisation.destroy_all
    Commande.destroy_all
    
    # Effacer les activites de la famille
    Famille.all.each do |f|
      f.etat = 'Inactif'
      f.membres.each do |m|
        m.activites=[]
        m.participations=[]
      end
      f.save!
    end
  end
  
  # Method pour annuler le rabais de pre-inscription des familles sans paiements
  def self.annulerRabais
    Famille.includes([:cotisation, :paiements]).where("etat = 'Actif'").each do |famille|
      if famille.paiements.empty? && 
           famille.cotisation.rabais_preinscription > 0 && 
           famille.cotisationTotal > 0 then
        famille.cotisation.rabais_preinscription = 0
        famille.cotisation.save!
        FamilleMailer.rabais_notif(famille, famille.courriels).deliver_now unless famille.courriels.empty?
      end
    end
  end
  
end
