class CreateNotes < ActiveRecord::Migration[5.0]
  def self.up
    create_table :notes, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|
      
      t.references :famille
      t.date :date
      t.string :auteur
      t.text :info

      t.timestamps
    end
    add_index :notes, [:famille_id], :unique => false, :name => 'par_famille'
  end

  def self.down
    remove_index :notes, :name => :par_famille
    drop_table :notes
  end
end
