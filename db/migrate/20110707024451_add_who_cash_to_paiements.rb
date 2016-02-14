class AddWhoCashToPaiements < ActiveRecord::Migration
  def self.up
    add_column :paiements, :par, :string, {:default => ''}
    add_column :paiements, :no_cheque, :integer, {:default => 0}
    add_column :paiements, :comptant, :boolean, {:default => false}
  end

  def self.down
    drop_column :paiements, :comptant, :no_cheque, :par
  end
end
