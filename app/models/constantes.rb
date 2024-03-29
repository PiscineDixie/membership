#
# coding: utf-8
# Class singleton pour les constantes d'operations
#
class Constantes < ApplicationRecord
  
  def self.instance
    cte = Constantes.take
    unless cte
      cte = Constantes.new
      cte.save!
    end
    return cte
  end
  
end
