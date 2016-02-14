class CreateParticipationsMembres < ActiveRecord::Migration
  def self.up
    create_table :participations_membres, :id => false, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|

      t.references :participation
      t.references :membre
    end
    add_index :participations_membres, [:membre_id], :unique => false, :name => 'par_membre'
    add_index :participations_membres, [:participation_id], :unique => false, :name => 'par_participation'
  end

  def self.down
    remove_index :participations_membres, :name => :par_membre
    remove_index :participations_membres, :name => :par_participation
    drop_table :participations_membres
  end
end
