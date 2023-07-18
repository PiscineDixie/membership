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
  
  def initialize
    @montantBase = ElementCotisation.new
    @montantNatation = ElementCotisation.new
    @montantBronze = ElementCotisation.new
    @montantActivite = ElementCotisation.new
    @rabaisPreInscription = 0 # Toujours taxable
    @adultesAdditionels = 0 # toujours taxable
  end
  
  def totalTaxable
    @montantBase.taxable + @montantNatation.taxable + @montantBronze.taxable + @montantActivite.taxable + @adultesAdditionels
  end
  
  def totalNonTaxable
    @montantBase.nonTaxable + @montantNatation.nonTaxable + @montantBronze.nonTaxable + @montantActivite.nonTaxable
  end
  
  def total
    self.totalTaxable() + self.totalNonTaxable()
  end

  def net
    self.total() - @rabaisPreInscription
  end
  
  # Retourne une array de paire[nom, montant] avec la description des couts
  def description(locale)
    res = Array.new
    res << [I18n.t("cotisation.base", locale: locale), @montantBase.total]
    res << [I18n.t("cotisation.activite", locale: locale), @montantActivite.total] unless @montantActivite.total == 0
    res << [I18n.t("cotisation.natation", locale: locale), @montantNatation.total] unless @montantNatation.total == 0
    res << [I18n.t("cotisation.medailles", locale: locale), @montantBronze.total] unless @montantBronze.total == 0
    res << [I18n.t("cotisation.adultes_supp", locale: locale), @adultesAdditionels] unless @adultesAdditionels == 0
    res
  end
  
  # Faire le calcul comme sur la base d'abonnement individuels
  def asIndividu(famille)
    ctes = Constantes.instance
    MontantCotisation.validate
    famille.membres.each do | m |
      if m.senior?
        @montantBase.taxable += ctes.baseSenior
        @rabaisPreInscription += ctes.rabaisPreInscriptionSenior if Date.today() <= ctes.finPreInscription
      else
        @montantBase.taxable += ctes.baseIndividu
        @rabaisPreInscription += ctes.rabaisPreInscriptionIndividu if Date.today() <= ctes.finPreInscription
      end
    end

    # Autres couts
    montantActiviteIndividu(famille)
    @montantNatation = montantDesCoursDeNatation(famille)
    @montantBronze = montantDesBronze(famille)
  end
  
  # Faire le calcul sur la base d'une famille.
  def asFamille(famille)
    ctes = Constantes.instance
    MontantCotisation.validate
    @montantBase.taxable = Constantes.instance.baseFamille
    
    # Adultes supplementaires
    num_adultes = famille.membres.sum { |m| m.adulte? ? 1 : 0 }
    if num_adultes > 2
      @adultesAdditionels = Constantes.instance.adulte_additionel * (num_adultes - 2)
    end
  
    # Autres couts
    montantActiviteFamille(famille)
    @montantNatation = montantDesCoursDeNatation(famille)
    @montantBronze = montantDesBronze(famille)
    
    # Rabais pour inscription hative
    @rabaisPreInscription = ctes.rabaisPreInscriptionFamille if Date.today() <= ctes.finPreInscription
  end
  
  
  # Calculer le montant pour le recu d'impot
  def montantRecu(famille, membre, annee)
    return 0 unless membre.eligibleRecu(annee)
    ctes = Constantes.instance
    montant = 0.0

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
        montant += ctes.activiteFamille.div(cnt, 2)
      else
        montant += ctes.activiteIndividu
      end
    end

    # Ajoute le prorata des course de natation
    if membre.activites.find_by_code(Activite::CodeCoursDeNatation)
      total = montantDesCoursDeNatation(famille).total()
      cnt = famille.membres.sum {|m| m.activites.where(code: Activite::CodeCoursDeNatation).count}
      montant += total.quo(cnt).round(2)
    end

    # Ajoute le prorata pour les cours de bronze
    mem_cnt = membre.activites.where(code: [Activite::CodeCroixDeBronze, Activite::CodeMedailleDeBronze]).count()
    if !mem_cnt.nil? && mem_cnt > 0
      total = montantDesBronze(famille).total()
      cnt = famille.membres.sum{|m| m.activites.where(code: [Activite::CodeCroixDeBronze, Activite::CodeMedailleDeBronze]).count}
      montant += (mem_cnt * total).quo(cnt).round(2)
    end

    montant
  end


  private

  # S'assurer que la data base est integre pour calculer les cotisations
  def self.validate
    act = Activite.find_by_code(Activite::CodeCoursDeNatation)
    if !act
      raise "Les cours de natation doivent avoir le code: " + Activite::CodeCoursDeNatation
    elsif !act.gratuite
      raise "Les cours de natation doivent être gratuit dans Activites."
    elsif act.cout == 0 or act.cout2 == 0
      raise "Les cours de natation doivent avoir un coût dans Activites."
    end
    
    act = Activite.find_by_code(Activite::CodeCroixDeBronze)
    if !act
      raise "La Croix de Bronze doit avoir le code: " + Activite::CodeCroixDeBronze
    elsif !act.gratuite
      raise "La Croix de Bronze doit être gratuite dans Activites."
    elsif act.cout == 0 or act.cout2 == 0
      raise "La Croix de Bronze doit avoir un coût dans Activites."
    end
    
    act = Activite.find_by_code(Activite::CodeMedailleDeBronze)
    if !act
      raise "La Médaille de Bronze doit avoir le code: " + Activite::CodeMedailleDeBronze
    elsif !act.gratuite
      raise "La Médaille de Bronze doit être gratuite dans Activites."
    elsif act.cout == 0 or act.cout2 == 0
      raise "La Médaille de Bronze doit avoir un coût dans Activites."
    end
  end


  # Calcule du montant pour activites
  def montantActiviteFamille(famille)
    return if !famille.ontDesActivites?
    
    # Est-ce qu'il y au moins un des membres qui a des activites et qui
    # a moins de quinze ans. Si oui, les frais sont non taxables
    famille.membres.each do | m |
      if m.aMoinsDeQuinzeAns? and m.aDesActivites?
        @montantActivite.nonTaxable = Constantes.instance.activiteFamille
        return
      end
    end
    
    @montantActivite.taxable = Constantes.instance.activiteFamille
  end
  
  # Calcule du montant pour activites pour individus
  def montantActiviteIndividu(famille)
    # Les frais sont differents pour les seniors et sont non-taxable pour < 15 ans
    ctes = Constantes.instance
    famille.membres.each do | m |
      if m.aDesActivites?
        if m.aMoinsDeQuinzeAns?
          @montantActivite.nonTaxable += ctes.activiteIndividu
        elsif m.senior?
          @montantActivite.taxable += ctes.activiteSenior
        else
          @montantActivite.taxable += ctes.activiteIndividu
        end
      end
    end
  end
  
  # Calcule du montant pour cours de natation (autre que bronze)
  def montantDesCoursDeNatation(famille)
    self.montantActiviteCouteuse(famille, [Activite::CodeCoursDeNatation])
  end

  # Calcule du montant pour cours de natation de bronze
  def montantDesBronze(famille)
    self.montantActiviteCouteuse(famille, [Activite::CodeCroixDeBronze, Activite::CodeMedailleDeBronze])
  end

  # calcule des frais pour les activites qui ont un frais specifique.
  # tenir compte du nombre dans la famille: On utilise "cout" pour le premier membre et "cout2" pour les autres
  def montantActiviteCouteuse(famille, codes)
    cnt = 0
    frais = ElementCotisation.new
    famille.membres.each do | membre| 
      codes.each do | id |
        act = membre.activites.find_by_code(id)
        if act
          cnt += 1
          if membre.aMoinsDeQuinzeAns?
            frais.nonTaxable += cnt > 1 ? act.cout2 : act.cout
          else
            frais.taxable += cnt > 1 ? act.cout2 : act.cout
          end
        end
      end
    end
    frais
  end
end
