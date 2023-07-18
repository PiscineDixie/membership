# coding: utf-8
class Note < ApplicationRecord

  belongs_to :famille, inverse_of: :notes
  
  before_save :set_date
  def set_date
    self.date = Date.today
  end

  # Les 50 premiers caractères de la note
  def sommaire
    self.info.slice(0, 50)
  end
end
