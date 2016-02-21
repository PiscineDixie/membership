# coding: utf-8
class Membre < ActiveRecord::Base
  
  Ecussons = ["Débutant", "Nageur", "Adulte"]
  
  # Une famille contient plusieurs membres
  belongs_to :famille, inverse_of: :membres
  
    
  # Enregistrer qu'un membre participe a plusieurs activites et vice-versa
  has_and_belongs_to_many :activites
  has_and_belongs_to_many :participations, :join_table => 'participations_membres'
  
  #
  # Callbacks
  #
  
  validate :verifications
  def verifications
    if abonneCoursDeNatation?
      unless Activite::CoursDeNatation.include?(self.cours_de_natation) && Activite::SessionCoursDeNatation.include?(self.session_de_natation)
        errors.add(:activites, prenomNom + ': Vous devez choisir un niveau et une session pour les cours de natation.')
      end
    end
        
    unless !self.prenom.blank? && !self.nom.blank?
      errors.add(:nom, prenomNom + ': Le nom et prenom doivent être entrés.')
    end
    unless Ecussons.include?(self.ecusson)
      errors.add(:ecusson, prenomNom + ": N'est pas valide.")
    end
  end
  
  # Enlever toutes les activites lorsqu'un membre est enleve.
  before_destroy :clear_activities
  def clear_activities
    self.activites.clear
    self.participations.clear
  end
  
  
  # Initializer.
  def initialize(parms = nil, options = {})
    
    logger.error "Creating new member: #{parms.to_yaml}"
    
    # Enlever les activites
    tmpActivites = parms && parms.delete(:activites) || nil
    tmpParticipations = parms && parms.delete(:participations) || nil
    
    super
    
    # Lorsque la date est sous forme de hash {:year, :month, :day}, faire la conversion
    if parms && parms[:naissance] && parms[:naissance][:year]
      nd = parms.delete(:naissance)
      self.naissance = Date.civil(nd[:year].to_i, nd[:month].to_i, nd[:day].to_i)
    else
      self.naissance = Date.civil(Date.today.year - 5, 7, 15)
    end
    
    saveActivites(tmpActivites)
    saveParticipations(tmpParticipations)
    
    # Des defaults
    self.nom = '' unless parms && parms[:nom]
    self.prenom = '' unless parms && parms[:prenom]
    self.activites.build unless parms
    self.participations.build unless parms
    self.nom.capitalize!
    self.prenom.capitalize!
  end
  
  
  # Mettre a jour les parametres
  def update(parms)
    dn = parms.delete(:naissance)
    self.naissance = Date.civil(dn[:year].to_i, dn[:month].to_i, dn[:day].to_i)
    saveActivites(parms.delete(:activites))
    saveParticipations(parms.delete(:participations))
    
    # s'assurer que les informations pour les lecons de natation ne sont pas presente
    # si pas de lecons. On efface l'input puisque plus valide.
    unless abonneCoursDeNatation?
      parms[:cours_de_natation] = parms[:session_de_natation] = ''
    end
    
    # Finir l'update des autres parametres du membre.
    return super
  end
  
  
  # Mettre a jour les activites etant donne la liste dans le hash donne
  # Les clefs du hash sont les codes, les valeurs sont les id des activites.
  def saveActivites(parms)
    if parms
      self.activite_ids = parms.values
    else
      self.activites.clear
    end
  end
  
  # Mettre a jour les activites etant donne la liste dans le hash donne
  # Les clefs du hash sont les codes, les valeurs sont les id des activites.
  def saveParticipations(parms)
    if parms
      self.participation_ids = parms.values
    else
      self.participations.clear
    end
  end
  
  # Retourne 'true' si la personne a moins de 15 ans le premier aout
  # Ceci permet d'eviter des taxes.
  def aMoinsDeQuinzeAns?
    Date.civil(Date.today().year, 8, 1).years_ago(15) < self.naissance
  end
  
  # Membre ayant plus de 65 ans dans l'annee courante avant le debut aout
  def senior?
    Date.civil(Date.today().year, 8, 1).years_ago(65) > self.naissance 
  end
  
  # Membre eligible pour un recu d'impot pour la condition physique des enfants
  def eligibleRecu(annee = Date.today().year)
    Date.civil(annee, 1, 1).years_ago(16) <= self.naissance
  end
  
  def nomPrenom
    return self.nom + ", " + self.prenom
  end
  
  def prenomNom
    return self.prenom + " " + self.nom
  end
  
  # Retourne une string avec la liste des codes d'activites du membre
  def listeActivites
    return "" if self.activites.empty?
    s = ""
    self.activites.each { | a |  s.empty? ? s << a.code : s << ', ' << a.code }
    return s
  end
  
  # Retourne true si le membre est inscrit a des activites non-gratuite
  def aDesActivites?
    self.activites.each do | a |
      if !a.gratuite
        return true
      end
    end
    false
  end
  
  # Retourne 'true' si le membre est abonne a l'activite donnee
  # On fait comme ceci parce que ca fonctionne meme si pas encore cree dans db
  def activite?(id)
    self.activites.each do | act |
      return true if act.id == id
    end
    return false
  end


  # Retourne 'true' si le membre est abonne a l'activite donnee
  # On fait comme ceci parce que ca fonctionne meme si pas encore cree dans db
  def participation?(id)
    self.participations.each do | act |
      return true if act.id == id
    end
    return false
  end


  # Retourne true si abonne a l'activite de cours de natation
  def abonneCoursDeNatation?
    ln =  Activite.natation
    return activite?(ln.id);
  end
  
  # Retourne true si le membre est "eligible" pour aider aux activites
  def peutAider?
    return Date.today().years_ago(13) > self.naissance
  end
  
  # Retourne la liste des membres actifs
  def self.membresActif
    return Membre.
      join("inner join familles as f on famille_id = f.id").
      where("etat = 'Actif'").
      order('nom, prenom')
  end
  
  # Retourne le nombre de membres actifs
  def self.nombreMembres
    return membresActif.size()
  end
  
  # Retourne le nombre de membres senior
  def self.nombreSeniors
    cnt = 0
    membresActif.each { |m| cnt = cnt + 1 if m.senior? }
    return cnt
  end
  
  # Retourne le total des activite
  def self.nombreActivites
    cnt = 0
    membresActif.each { |m| cnt = cnt + m.activites.size }
    return cnt
  end
  
end
