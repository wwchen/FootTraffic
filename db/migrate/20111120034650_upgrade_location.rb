class UpgradeLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :address, :string
    add_column :locations, :phone,   :string
    add_column :locations, :icon,    :string
    add_column :locations, :rating,  :float
    add_column :locations, :types,   :string
    add_column :locations, :url,     :string
    add_column :locations, :website, :string
  end

  def self.down
    remove_column :locations, :address
    remove_column :locations, :phone  
    remove_column :locations, :icon   
    remove_column :locations, :rating 
    remove_column :locations, :types  
    remove_column :locations, :url    
    remove_column :locations, :website
  end
end
