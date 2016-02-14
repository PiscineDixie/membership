class CreateParticipations < ActiveRecord::Migration
  def self.up
    create_table :participations, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.string :description_fr,  :null => false
      t.string :description_en,  :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :participations
  end
end
