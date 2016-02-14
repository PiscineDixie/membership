# coding: utf-8
class Participation < ActiveRecord::Base
  
  validates_presence_of :description_fr, :description_en
  
  # Enregistrer qu'une activite a plusieurs membres
  has_and_belongs_to_many :membres, :join_table => 'participations_membres'
  
  def self.nombreActivites
    return Participation.count
  end
  
    # Retourner la liste des activites. Descriptions de chacune
  def self.descriptions
    res = Hash.new
    acts = Participation.order(:description_fr).select('description_fr, id')
    acts.each do | act |
      res[act.description_fr] = act.id
    end
    return res
  end

end
