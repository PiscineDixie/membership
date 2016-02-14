class LoadActivitesData < ActiveRecord::Migration
  def self.up
    down
      a = Activite.new(
        :code => 'LN',
        :description_fr => 'Lecons de natation',
        :description_en => 'EN Lecons de natation',
        :gratuite => true,
        :cout => '40.00')
      a.save!
      
      a = Activite.new(
        :code => 'WP',
        :description_fr => 'Water-polo',
        :description_en => 'EN Water-polo',
        :gratuite => false,
        :cout => '0.00')
      a.save!

      a = Activite.new(
        :code => 'JD',
        :description_fr => 'Jeune dirigeant',
        :description_en => 'EN Jeune dirigeant',
        :gratuite => true,
        :cout => '0.00')
      a.save!
  
      a = Activite.new(
        :code => 'MB',
        :description_fr => 'Médaille de Bronze',
        :description_en => 'EN Médaille de Bronze',
        :gratuite => true,
        :cout => '125.00')
      a.save!
      
      a = Activite.new(
        :code => 'CB',
        :description_fr => 'Croix de Bronze',
        :description_en => 'EN Croix de Bronze',
        :gratuite => true,
        :cout => '125.00')
      a.save!
  end

  def self.down
    Activite.delete_all
  end
end
