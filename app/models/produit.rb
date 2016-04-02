# coding: utf-8
class Produit < ActiveRecord::Base
  
  validates_numericality_of :prix
  validates_presence_of :description_en, :description_fr, :titre_fr, :titre_en, :images
  
end