class LoadActivitesMembresData < ActiveRecord::Migration[5.0]
  def self.up
    down
    Membre.find(:all).each do | m |
      m.activites << Activite.find(:first)
      m.session_de_natation = Activite::SessionCoursDeNatation[0]
      m.cours_de_natation = Activite::CoursDeNatation[0]
      m.activites << Activite.find_by_code('MB')
      m.save!
    end
  end

  def self.down
    Membre.find(:all).each do | m |
      m.activites.delete_all
      m.save!
    end
  end
end
