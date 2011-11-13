class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :twitter_id
      t.string :name
      t.string :latitude
      t.string :longitude
      t.string :daily
      t.string :weekly
      t.string :annually
      t.string :bounding_box
      t.string :place_type

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
