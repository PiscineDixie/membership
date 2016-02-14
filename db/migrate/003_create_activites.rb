class CreateActivites < ActiveRecord::Migration
  def self.up
    create_table :activites, :options => 'ENGINE=InnoDB DEFAULT CHARSET=UTF8' do |t|
      t.string :code,            :null => false
      t.string :description_fr,  :null => false
      t.string :description_en,  :null => false
      t.string :url_fr
      t.string :url_en
      t.boolean :gratuite
      t.decimal :cout, :precision => 8, :scale => 2, :default => 0

      t.timestamps
    end
    add_index :activites, [:code], :unique => true, :name => 'par_code'
  end

  def self.down
    remove_index :activites, :name => :par_code
    drop_table :activites
  end
end
