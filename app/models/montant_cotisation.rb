# coding: utf-8
# Structure pour Les donnees de calcul de la cotisation
class ElementCotisation
  attr_accessor :taxable
  attr_accessor :nonTaxable
  
  def initialize
    @taxable = 0
    @nonTaxable = 0
  end
  
  def total
    @taxable + @nonTaxable
  end
  
end

class MontantCotisation
  attr_accessor :montantBase      # Montant pour la cotisation de base
  attr_accessor :montantNatation  # Montant des frais pour les cours de natation
  attr_accessor :montantBronze    # Montant des frais pour les cours de croix/medaille de bronze
  attr_accessor :montantActivite  # Montant des frais pour participation aux activites
  attr_accessor :rabaisPreInscription
  
  # Une array de deux pour chacun: taxable, non-Taxable
  def initialize
    @montantBase = ElementCotisation.new
    @montantNatation = ElementCotisation.new
    @montantBronze = ElementCotisation.new
    @montantActivite = ElementCotisation.new
    @rabaisPreInscription = 0 # Toujours taxable
  end
  
  def totalTaxable
    @montantBase.taxable + @montantNatation.taxable + @montantBronze.taxable + @montantActivite.taxable
  end
  
  def totalNonTaxable
    @montantBase.nonTaxable + @montantNatation.nonTaxable + @montantBronze.nonTaxable + @montantActivite.nonTaxable
  end
  
  def total
    totalTaxable() + totalNonTaxable()
  end
  
  # Retourne une array de paire[nom, montant] avec la description des couts
  def description(english)
    res = Array.new
    res << [english ? 'Base membership'     : 'Cotisation de base', @montantBase.total]
    res << [english ? 'Activity membership' : 'Cotisation pour activités', @montantActivite.total] unless @montantActivite.total == 0
    res << [english ? 'Swimming lessons'    : 'Leçons de natation', @montantNatation.total] unless @montantNatation.total == 0
    res << [english ? 'Bronze Medal/Cross'  : 'Médaille/Croix de Bronze', @montantBronze.total] unless @montantBronze.total == 0
    res
  end
  
  # S'assurer que la data base est integre pour calculer les cotisations
  def self.validate
    act = Activite.find_by_code(Activite::CodeCoursDeNatation)
    if !act
      raise "Les cours de natation doivent avoir le code: " + Activite::CodeCoursDeNatation
    elsif !act.gratuite
      raise "Les cours de natation doivent être gratuit dans Activites."
    elsif act.cout == 0
      raise "Les cours de natation doivent avoir un coût dans Activites."
    end
    
    act = Activite.find_by_code(Activite::CodeCroixDeBronze)
    if !act
      raise "La Croix de Bronze doit avoir le code: " + Activite::CodeCroixDeBronze
    elsif !act.gratuite
      raise "La Croix de Bronze doit être gratuite dans Activites."
    elsif act.cout == 0
      raise "La Croix de Bronze doit avoir un coût dans Activites."
    end
    
    act = Activite.find_by_code(Activite::CodeMedailleDeBronze)
    if !act
      raise "La Médaille de Bronze doit avoir le code: " + Activite::CodeMedailleDeBronze
    elsif !act.gratuite
      raise "La Médaille de Bronze doit être gratuite dans Activites."
    elsif act.cout == 0
      raise "La Médaille de Bronze doit avoir un coût dans Activites."
    end
  end
  
  # Faire le calcul comme sur la base d'abonnement individuels
  def asIndividu(famille)
    ctes = Constantes.instance
    MontantCotisation.validate
    famille.membres.each do | m |
      if m.senior?
        self.montantBase.taxable += ctes.baseSenior
        self.rabaisPreInscription += ctes.rabaisPreInscriptionSenior if Date.today() <= ctes.finPreInscription
      else
        self.montantBase.taxable += ctes.baseIndividu
        self.rabaisPreInscription += ctes.rabaisPreInscriptionIndividu if Date.today() <= ctes.finPreInscription
      end
    end

    # Autres couts
    montantActiviteIndividu(famille)
    montantDesCoursDeNatation(famille)
    montantDesBronze(famille)
  end
  
  # Faire le calcul sur la base d'une famille. Voir "calcul" pour le retour
  def asFamille(famille)
    ctes = Constantes.instance
    MontantCotisation.validate
    self.montantBase.taxable = Constantes.instance.baseFamille
    
    # Autres couts
    montantActiviteFamille(famille)
    montantDesCoursDeNatation(famille)
    montantDesBronze(famille)
    
    # Rabais pour inscription hative
    self.rabaisPreInscription += ctes.rabaisPreInscriptionFamille if Date.today() <= ctes.finPreInscription
  end
  
  
  # Calcule du montant pour activites
  # Argument est un MontantCotisation que l'on met a jour
  def montantActiviteFamille(famille)
    return if !famille.ontDesActivites?
    
    # Est-ce qu'il y au moins un des membres qui a des activites et qui
    # a moins de quinze ans. Si oui, les frais sont non taxables
    famille.membres.each do | m |
      if m.aMoinsDeQuinzeAns? and m.aDesActivites?
        self.montantActivite.nonTaxable = Constantes.instance.activiteFamille
        return
      end
    end
    
    self.montantActivite.taxable = Constantes.instance.activiteFamille
  end
  
 # Calcule du montant pour activites pour individus
  # Argument est un MontantCotisation que l'on met a jour
  def montantActiviteIndividu(famille)
    # Les frais sont differents pour les seniors et sont non-taxable pour < 15 ans
    ctes = Constantes.instance
    famille.membres.each do | m |
      if m.aDesActivites?
        if m.aMoinsDeQuinzeAns?
          self.montantActivite.nonTaxable += ctes.activiteIndividu
        elsif m.senior?
          self.montantActivite.nonTaxable += ctes.activiteSenior
        else
          self.montantActivite.taxable += ctes.activiteIndividu
        end
      end
    end
  end
  
  
  # Calcule du montant pour cours de natation (autre que bronze)
  # Argument est un MontantCotisation que l'on met a jour
  def montantDesCoursDeNatation(famille)
    famille.membres.each { | m | montantDesCoursDeNatationMembre(m) }
  end
    
  # Calcule du montant pour cours de natation (autre que bronze)
  # Argument est un MontantCotisation que l'on met a jour
  def montantDesCoursDeNatationMembre(membre)
    act = Activite.find_by_code(Activite::CodeCoursDeNatation)
    if membre.abonneCoursDeNatation?
      if membre.aMoinsDeQuinzeAns?
        self.montantNatation.nonTaxable += act.cout
      else
        self.montantNatation.taxable += act.cout
      end
    end
  end

  # Calcule du montant pour cours de natation de bronze
  # Retourne une paire [taxable non-taxable]
  def montantDesBronze(famille)
    famille.membres.each { | m |  montantDesBronzesMembre(m) }
  end
  
  def montantDesBronzesMembre(membre)
    act = membre.activites.find_by_code(Activite::CodeCroixDeBronze)
    if act
      if membre.aMoinsDeQuinzeAns?
        self.montantBronze.nonTaxable += act.cout
      else
        self.montantBronze.taxable += act.cout
      end
    end
    act = membre.activites.find_by_code(Activite::CodeMedailleDeBronze)
    if act
      if membre.aMoinsDeQuinzeAns?
        self.montantBronze.nonTaxable += act.cout
      else
        self.montantBronze.taxable += act.cout
      end
    end
  end
  
  # Calculer le montant pour le recu d'impot
  def montantRecu(famille, membre, annee)
    return 0 unless membre.eligibleRecu(annee)
    montantDesCoursDeNatationMembre(membre)
    montantDesBronzesMembre(membre)
    ctes = Constantes.instance
    montant = total
    
    # Si le membre a des activites, ajouter sa part de la cotisation de base
    if montant > 0 || !membre.activites.empty?
      if famille.cotisation.familiale
        montant += (ctes.baseFamille + famille.cotisation.ajustements).quo(famille.membres.size).round(2)
      else
        montant += ctes.baseIndividu + famille.cotisation.ajustements 
      end
    end

    # Si un montant pour activites payantes, ajouter sa part
    if membre.aDesActivites?
      if famille.cotisation.familiale
        cnt = 0
        famille.membres.each { | m | cnt += 1 if m.aDesActivites? }
        montant = montant + ctes.activiteFamille.div(cnt, 2)
      else
        montant = montant + ctes.activiteIndividu
      end
    end
    
    return montant
  end
  
end
