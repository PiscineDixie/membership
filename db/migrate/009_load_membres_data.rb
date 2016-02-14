class LoadMembresData < ActiveRecord::Migration
  def self.up
    down
    
    # Une famille avec 2 membres
    f = Famille.create(
      :adresse1 => '1, 46ieme Avenue',
      :tel_soir => '5146349461',
      :code_postal => 'E3V2S1',
      :province => 'QC',
      :ville => 'Lachine',
      :courriel1 => 'pierre.belzile@gmail.com',
      :langue => 'FR',
      :etat => 'Inactif')
      
    f.membres << Membre.create(
      :nom => 'Belzile',
      :prenom => 'Pierre',
      :naissance => '1964-02-26',
      :ecusson => 'Nageur')

    f.membres << Membre.create(
      :nom => 'Preston',
      :prenom => 'Stephanie',
      :naissance => '1964-06-26',
      :ecusson => 'Nageur')
    
    f.save!
    
    
    # Une famille avec 2 seniors
    f = Famille.create(
      :adresse1 => '2, 46ieme Avenue',
      :tel_soir => '5146349462',
      :code_postal => 'E3V2S2',
      :province => 'QC',
      :ville => 'Lachine',
      :courriel1 => 'pierre.belzile@gmail.com',
      :langue => 'EN',
      :etat => 'Inactif')
      
    f.membres << Membre.create(
      :nom => 'Vieux',
      :prenom => 'SonPere',
      :naissance => '1914-02-26',
      :ecusson => 'Nageur')
    
    f.membres << Membre.create(
      :nom => 'Vieux',
      :prenom => 'SaMere',
      :naissance => '1914-06-26',
      :ecusson => 'Nageur')
    f.save!


    f = Famille.create(
      :adresse1 => '3, 46ieme Avenue',
      :tel_soir => '5146349463',
      :code_postal => 'E3V2S3',
      :province => 'QC',
      :ville => 'Lachine',
      :courriel1 => 'pierre.belzile@gmail.com',
      :langue => 'FR',
      :etat => 'Inactif')
      
    f.membres << Membre.create(
      :nom => 'Seul',
      :prenom => 'Un',
      :naissance => '1994-02-26',
      :ecusson => 'Nageur')
    
    f.save!
  end

  def self.down
    Famille.delete_all
  end
end
