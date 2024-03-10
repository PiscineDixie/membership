# coding: utf-8
class Activite < ApplicationRecord
  
  validates_numericality_of :cout, :cout2
  validates_uniqueness_of :code
  validates_presence_of :code, :description_fr
  
  # Enregistrer qu'une activite a plusieurs membres
  has_and_belongs_to_many :membres
  
  #
  # Constantes
  #
  CoursDeNatation = ["Parent et enfant 1", "Parent et enfant 2", "Parent et enfant 3", "Préscolaire 1", "Préscolaire 2", "Préscolaire 3", "Préscolaire 4", "Préscolaire 5", "Nageur 1", "Nageur 2", "Nageur 3","Nageur 4","Nageur 5","Nageur 6","Jeune  Initié", "Jeune Sauveteur Averti","Jeune Sauveteur Expert"]
  SessionCoursDeNatation = ["matin en semaine", "soir en semaine"]
  
  # Ces codes doivent etre dans la base de donnees.
  CodeCoursDeNatation = Constantes.instance.codeLeconNatation;
  CodeMedailleDeBronze = 'MB';
  CodeCroixDeBronze = 'CB';
  
  # Retourner la liste des activites. Descriptions de chacune
  def self.descriptions
    res = Hash.new
    acts = Activite.order(:description_fr).select('description_fr, id')
    acts.each do | act |
      res[act.description_fr] = act.id
    end
    return res
  end
  
  def self.natation
    return Activite.find_by_code(Activite::CodeCoursDeNatation)
  end
  
  def membreNatation(session, niveau)
    return self.membres.order("nom, prenom").
      where("cours_de_natation = :cours and session_de_natation = :session", { :cours => niveau, :session => session})
  end
  
  def self.nombreActivites
    return Activite.count
  end
  
  # Generer un tableau avec l'activite et son nombre de membres
  # @return [[<activite>, <nombre de participants>], ...]
  def self.sommaire
    return Activite.joins(:membres).group(:description_fr).count
  end
end
