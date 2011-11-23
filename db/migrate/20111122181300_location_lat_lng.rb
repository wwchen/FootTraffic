class LocationLatLng < ActiveRecord::Migration
  def self.up
    remove_column :locations, :geom
    add_column :locations, :latitude, :float
    add_column :locations, :longitude, :float
  end

  def self.down
    remove_column :locations, :latitude
    remove_column :locations, :longitude
  end
end
