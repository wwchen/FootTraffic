class UpdateModels < ActiveRecord::Migration
  def self.up
    add_column :locations, :geom, :point
    remove_column :locations, :latitude
    remove_column :locations, :longitude
  end

  def self.down
    add_column :locations, :latitude, :float
    add_column :locations, :longitude, :float
    remove_column :locations, :geom
  end
end
